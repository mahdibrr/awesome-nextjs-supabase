# Next.js 15 cache + async params — runnable example

A self-contained, **vitest-only** example that reproduces three real
production incidents and verifies the fixes with automated tests. No Next.js
server, no Supabase, no database — the testable logic (params extraction,
revalidate-call mapping) is isolated into pure TypeScript modules so the tests
run with just `vitest`.

## What this demonstrates

| Incident | One-line summary |
|---|---|
| **INC-020** | Next.js 15 made `params` / `searchParams` a `Promise`. Reading `.id` synchronously off the Promise resolves to `undefined` / build error. |
| **INC-008** | `revalidatePath` runs but stale data persists — wrong path arg, or path/tag mismatch with the cached fetch key. |
| **INC-011** | Server Action write succeeds but the UI reads old state — stale cache tags; need `revalidateTag` tied to the cached fetch key. |

## The two bugs

### Bug 1 — async params (INC-020)

```ts
// BROKEN: params is Promise<{ id }>, not { id }
const id = (params as { id: string }).id; // undefined at runtime
```

In Next.js 15 the dynamic-route `params` argument became a Promise. Accessing
`.id` on the Promise object returns `undefined` (a Promise has no `.id`
property), so the page reads the wrong id, fetches the wrong row, or 404s.

### Bug 2 — wrong revalidate target (INC-008 / INC-011)

```ts
// BROKEN: revalidates the admin route, never the public route, never the tag
revalidatePath('/admin/posts');
```

The cached fetch in `app/posts/[id]/page.tsx` uses tag `post:${id}` and is
rendered at route `/posts/${id}`. A Server Action that revalidates
`/admin/posts` busts neither the data cache (no `revalidateTag('post:${id}')`)
nor the public route cache. The write succeeds; the UI stays stale.

## The fixes

### Fix 1 — `await params`

```ts
const { id } = await params;
```

Matches the real Next.js 15 contract. See `src/params/fixed.ts`.

### Fix 2 — the tag + path decision matrix

A single pure function, `revalidateFor(mutation)`, maps a mutation to the
correct revalidate calls — **both** the tag the cached fetch used (busts the
data cache) **and** the path of the route that renders it (busts the router
cache). The Server Action calls it; the tests assert against it. One source of
truth, reusable everywhere. See `src/revalidate/matrix.ts`.

```ts
revalidateFor({ type: 'update-post', id: 'p1' })
// => [{ kind: 'tag', target: 'post:p1' }, { kind: 'path', target: '/posts/p1' }]
```

## Run the tests

```bash
npm install
npm test
```

Requirements: Node 20+ and npm. The only dev dependency is `vitest`.

## Drop into your Next 15 app

The `.broken` / `.fixed` files use Next-15-style signatures but are plain TS,
so no `next` import is needed to run the tests. To wire them into a real
Next.js 15 `app/` directory:

```ts
// app/posts/[id]/page.tsx
import { getPostIdFixed } from '@/examples/nextjs15-cache-and-params/src/params/fixed';

export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const id = await getPostIdFixed(params);
  const post = await fetch(`${process.env.SUPABASE_URL}/rest/v1/posts?id=eq.${id}`, {
    next: { tags: [`post:${id}`] }, // cached-fetch key — must match the matrix
  }).then((r) => r.json());
  return <pre>{JSON.stringify(post, null, 2)}</pre>;
}
```

```ts
// app/posts/[id]/actions.ts (Server Action)
'use server';
import { revalidateFixed } from '@/examples/nextjs15-cache-and-params/src/revalidate/fixed';

export async function updatePost(id: string, body: Partial<Post>) {
  await supabase.from('posts').update(body).eq('id', id);
  for (const call of revalidateFixed({ type: 'update-post', id })) {
    if (call.kind === 'tag') revalidateTag(call.target);
    else revalidatePath(call.target);
  }
}
```

## The decision matrix

| Mutation | Tag (data cache) | Path (router cache) |
|---|---|---|
| `update-post` | `post:${id}` | `/posts/${id}` |
| `delete-post` | `post:${id}` | `/posts`, `/posts/${id}` |

Rule of thumb: the tag must match the `next: { tags: [...] }` key the cached
fetch used, and the path must match the route that renders it. Missing either
one is the stale-UI bug.

## References

- [Revalidate stale postmortem](../../reference/playbooks/revalidate-stale-postmortem.md)
- [Next.js 15 async params postmortem](../../reference/playbooks/nextjs15-async-params-postmortem.md)
- [Incident index](../../reference/incident-index/README.md)