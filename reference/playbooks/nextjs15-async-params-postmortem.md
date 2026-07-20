# INC-020: Next.js 15 made `params` and `searchParams` async (Promise) — accessing them synchronously breaks the build or returns undefined

Last verified: 2026-07-19
Pinned to: Next.js 15 App Router (the `params` and `searchParams` props of Pages, Layouts, Route Handlers, `generateMetadata`, `generateViewport`, and metadata image files are **Promises** in 15; in Next.js 14 they were plain objects). Companion to [INC-008: revalidatePath runs but stale data persists](./revalidate-stale-postmortem.md) — both are Next.js 15 breaking-change incidents worth pairing in any 14 → 15 upgrade review.

## Symptom

You bump `next` from 14 to 15. No app code changes. Three failure shapes, any of which can fire:

1. **Build-time type error.** `next build` (or `tsc`) fails on a dynamic route page, layout, route handler, or `generateMetadata`:

   ```
   Error: Route "/posts/[id]" used `params.id`. `params` should be awaited before using its properties.
   ```

   or, in TypeScript-strict projects:

   ```
   TS2339: Property 'id' does not exist on type 'Promise<{ id: string }>'.
   ```

2. **Runtime `undefined`.** The build passes (you relaxed types or are on JS), and the page renders — but `params.id` is `undefined`. A `fetch(`/api/posts/${params.id}`)` hits `/api/posts/undefined`, the DB query returns nothing, and the user sees a blank detail page or a 404-shaped dashboard. No exception thrown.
3. **Runtime throw.** Code that dereferences further — `params.id.toUpperCase()`, or `searchParams.q.split(',')` — throws `TypeError: Cannot read properties of undefined (reading 'toUpperCase'`)` / `(... 'split')` in the Server Component render path. The route 500s.

The "it worked in 14" trap fires here: the version bump is the only change, so teams look for a regression in their own code (a bad deploy, a bad migration) before realizing the prop type itself changed.

## Impact

Build-blocking for typed projects (CI goes red on the version bump alone, blocking every other PR until the params access is rewritten). For JS or loosely-typed projects, the failure is silent at build time and only surfaces in production as `undefined` values or 500s on dynamic routes — exactly the routes that handle money (tenant-scoped dashboards, `/invoices/[id]`, `/accounts/[slug]`). Because the error is on the read path and not the write path, data is correct in Postgres but invisible in the UI; users reload, get the same blank, and open tickets. Search- and filter-driven pages (`?q=...`, `?page=2`) break the same way via `searchParams`.

## Root cause

Next.js 15 made request-time APIs **asynchronous** to support streaming and Partial Prerendering (PPE) — the server can stream the static shell of a page and only suspend the subtrees that actually need the dynamic, request-specific value. To do that, the value has to be a Promise the renderer can await on its own schedule.

The APIs affected (per the [Next.js 15 upgrade guide](https://nextjs.org/docs/app/guides/upgrading/version-15)):

- `cookies()`, `headers()`, `draftMode()` from `next/headers` (covered separately in INC-001).
- **`params`** in `layout.js`, `page.js`, `route.js`, `default.js`, `generateMetadata`, `generateViewport`, and the metadata image files (`opengraph-image`, `twitter-image`, `icon`, `apple-icon`).
- **`searchParams`** in `page.js`.

In Next.js 14 the signature was:

```tsx
export default async function Page({ params }: { params: { id: string } }) {
  const { id } = params // sync — works
}
```

In Next.js 15 the signature is:

```tsx
export default async function Page(props: { params: Promise<{ id: string }> }) {
  const params = await props.params
  const { id } = params // async — must await first
}
```

Code that does `const id = params.id` in 15 reads the `.id` property off a **Promise object**, not off the resolved params. That returns `undefined` at runtime, and TypeScript (with the new types) flags it at build time. The fix is always the same shape: `await` the prop, then destructure.

Two scope clarifications that bite in practice:

- **`generateStaticParams` is NOT a Promise.** It still returns a synchronous array of plain objects. Only the page/layout `params` *prop* is a Promise. Don't `await` inside `generateStaticParams`.
- **Client Components do not get a Promise prop you can `await`.** A Server Component can be `async`, but a Client Component cannot. In a Client Component, unwrap the Promise with React 19's `use()` hook: `const params = use(props.params)`. This is the documented boundary — see the [upgrade guide's client component section](https://nextjs.org/docs/app/guides/upgrading/version-15).

## Detection (run these now)

### 1. Read the build error

The canonical Next.js error text is:

```
Route "/posts/[id]" used `params.id`. `params` should be awaited before using its properties.
```

Read more: https://nextjs.org/docs/messages/sync-dynamic-apis

If you see this, the offending file and the property access are named directly. If TypeScript caught it first, the error is `TS2339: Property 'X' does not exist on type 'Promise<{ ... }>'`.

### 2. Grep your codebase for sync access

The pattern is property access on `params` or `searchParams` not preceded by `await`. A conservative ripgrep that catches the common cases:

```bash
# Sync property access on params/searchParams props in App Router files.
# Matches `params.id`, `searchParams.q`, `const { id } = params`, etc.
rg --type ts --type tsx \
  -n '\b(params|searchParams)\.\w' \
  app/

# Even stricter: destructuring of params without an await on the line.
rg -n 'const\s*\{[^}]*\}\s*=\s*(params|searchParams)\b' app/ \
  | rg -v 'await '
```

Caveats: the grep will false-positive on `await params` followed by `params.slug` on the *next* line (that's the fixed form). Walk each hit and confirm whether the prop was awaited *before* the property access. An AST-based check is more reliable — see Prevention.

### 3. Run the codemod in dry-run mode

The official codemod is `next-async-request-api` (NOT `async-request-headers` — that name does not exist; see the [codemods list](https://nextjs.org/docs/15/app/guides/upgrading/codemods)). Dry-run it to see every site it wants to change:

```bash
npx @next/codemod@latest next-async-request-api . --dry --print
```

The codemod transforms `cookies()`, `headers()`, `draftMode()`, and `params`/`searchParams` in the page/route entries (`page.js`, `layout.js`, `route.js`, `default.js`) plus `generateMetadata` / `generateViewport`. Where it cannot auto-fix (e.g. a Client Component it can't make `async`), it inserts a `React.use()` unwrap or a `// @next/codemod` comment / `UnsafeUnwrapped*` typecast for manual review. **Your build will error until those review markers are removed** — that's intentional.

## Fix

The fix is always: `await` the prop, then read properties off the resolved object. Three before/after shapes that cover ~all real cases.

### Dynamic route page (`app/posts/[id]/page.tsx`)

Before (Next.js 14):

```tsx
// app/posts/[id]/page.tsx — Next.js 14
type Params = { id: string }

export default async function Page({ params }: { params: Params }) {
  const { id } = params
  const post = await fetch(`https://api.example.com/posts/${id}`).then(r => r.json())
  return <article>{post.title}</article>
}
```

After (Next.js 15):

```tsx
// app/posts/[id]/page.tsx — Next.js 15
type Params = Promise<{ id: string }>

export default async function Page(props: { params: Params }) {
  const params = await props.params
  const { id } = params
  const post = await fetch(`https://api.example.com/posts/${id}`).then(r => r.json())
  return <article>{post.title}</article>
}
```

Gotcha: do not `await props.params` twice in the same render tree — it deopts streaming. Await once at the top of the page and pass the resolved plain object to children.

### Route handler (`app/api/posts/[id]/route.ts`)

Before (Next.js 14):

```tsx
// app/api/posts/[id]/route.ts — Next.js 14
type Params = { id: string }

export async function GET(request: Request, segmentData: { params: Params }) {
  const params = segmentData.params
  const slug = params.id
  return Response.json(await getPost(slug))
}
```

After (Next.js 15):

```tsx
// app/api/posts/[id]/route.ts — Next.js 15
type Params = Promise<{ id: string }>

export async function GET(request: Request, segmentData: { params: Params }) {
  const params = await segmentData.params
  const slug = params.id
  return Response.json(await getPost(slug))
}
```

### `generateMetadata` (and `generateViewport`)

Before (Next.js 14):

```tsx
// app/posts/[id]/page.tsx — Next.js 14
type Params = { id: string }

export function generateMetadata({ params }: { params: Params }) {
  const { id } = params
  return { title: `Post ${id}` }
}
```

After (Next.js 15):

```tsx
// app/posts/[id]/page.tsx — Next.js 15
type Params = Promise<{ id: string }>

export async function generateMetadata(props: { params: Params }) {
  const params = await props.params
  const { id } = params
  return { title: `Post ${id}` }
}
```

### Client Component boundary

In a Client Component you **cannot** `await` — the component can't be `async`. Use React 19's `use()` hook:

```tsx
// app/posts/[id]/client-child.tsx — Next.js 15, Client Component
'use client'
import { use } from 'react'

type Params = Promise<{ id: string }>

export default function PostClientChild(props: { params: Params }) {
  const params = use(props.params)
  const { id } = params
  return <button onClick={() => share(id)}>Share</button>
}
```

Do not cast to `UnsafeUnwrapped*` as a permanent fix — that's the [temporary compatibility shim](https://nextjs.org/docs/app/guides/upgrading/version-15) that logs a dev warning and **is removed in Next.js 16**, where sync access throws. It's a stopgap for one release, not a fix.

### `dynamic = 'force-dynamic'` does not fix this

Setting `export const dynamic = 'force-dynamic'` makes the *route* dynamic (server-rendered on demand), but it does **not** make `params` synchronous again. The prop is a Promise regardless of rendering mode. Do not reach for `force-dynamic` to avoid the await — it won't help.

## Prevention

1. **Pin the Next version** in `package.json` (`"next": "15.x.y"`, not `^15`) so a minor bump can't silently change types under you. Re-run the codemod on every major bump.
2. **Run the upgrade codemod in CI on bumps.** Add a step to your upgrade pipeline:

   ```bash
   # Dry-run the codemod against a PR branch; fail if it reports changes.
   npx @next/codemod@latest next-async-request-api . --dry --print
   ```

   Any output means the PR introduced sync access that the codemod would rewrite — block merge until the author awaits `params`/`searchParams` properly.
3. **AST gate that fails on sync property access.** The grep in Detection has false positives; a tiny AST check is more reliable. Example with `@typescript-eslint`-style logic (sketch — adapt to your toolchain):

   ```js
   // scripts/check-async-params.mjs — run in CI
   // Fails if a Server Component / route handler / generateMetadata reads
   // params.X or searchParams.X without a preceding `await <prop>` in the same scope.
   // Uses ts-morph; ~40 lines. Excludes files with 'use client' (use() hook is the fix there).
   ```

   The rule: in any file matching `app/**/{page,layout,route,default,opengraph-image,twitter-image,icon,apple-icon}.{ts,tsx,js,jsx}` and in any `generateMetadata` / `generateViewport` export, a `MemberExpression` with object `params` or `searchParams` must be preceded (in the same function body) by `await params` / `await searchParams` (or `use(params)` / `use(searchParams)` for client components). Fail the build otherwise.
4. **PR checklist line:** "Does this PR touch `params` or `searchParams`? If yes: awaited in every page/layout/route-handler/metadata that reads them? Shared type files updated (the codemod does not follow imports)?"

## References

- Next.js 15 upgrade guide (async request APIs) — https://nextjs.org/docs/app/guides/upgrading/version-15
- Next.js 15 blog post — https://nextjs.org/blog/next-15
- Next.js codemods list (`next-async-request-api`) — https://nextjs.org/docs/15/app/guides/upgrading/codemods
- `sync-dynamic-apis` error reference — https://nextjs.org/docs/messages/sync-dynamic-apis
- Page file convention (`params` / `searchParams`) — https://nextjs.org/docs/app/api-reference/file-conventions/page
- Layout file convention (`params`) — https://nextjs.org/docs/app/api-reference/file-conventions/layout
- Route Handler file convention (`params`) — https://nextjs.org/docs/app/api-reference/file-conventions/route
- `opengraph-image` / metadata file convention (`params`) — https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image
- [INC-008: revalidatePath runs but stale data persists](./revalidate-stale-postmortem.md)