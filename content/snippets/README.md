# Snippets

These snippets are intentionally small. Treat them as starting points and adapt them to your project structure.

## Supabase Auth Setup

Server client example:

```ts
import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        },
      },
    }
  );
}
```

Browser client example:

```ts
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

## Next.js Middleware Auth Protection

```ts
import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request,
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options);
          });
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user && request.nextUrl.pathname.startsWith("/dashboard")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return response;
}

export const config = {
  matcher: ["/dashboard/:path*"],
};
```

## RLS Policy Examples

User-owned rows:

```sql
alter table public.projects enable row level security;

create policy "Users can read their own projects"
on public.projects
for select
to authenticated
using (owner_id = auth.uid());

create policy "Users can insert their own projects"
on public.projects
for insert
to authenticated
with check (owner_id = auth.uid());
```

Team-owned rows:

```sql
create policy "Team members can read team projects"
on public.projects
for select
to authenticated
using (
  exists (
    select 1
    from public.team_members
    where team_members.team_id = projects.team_id
      and team_members.user_id = auth.uid()
  )
);
```

## API Helper

Server-only helper for loading the current user:

```ts
import { createClient } from "@/lib/supabase/server";

export async function requireUser() {
  const supabase = await createClient();

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user) {
    throw new Error("Unauthorized");
  }

  return user;
}
```

Route handler pattern:

```ts
import { NextResponse } from "next/server";
import { requireUser } from "@/lib/auth/require-user";

export async function GET() {
  const user = await requireUser();

  return NextResponse.json({
    id: user.id,
    email: user.email,
  });
}
```

## External Snippet Resources

Use these official docs, repos, and tools when turning snippets into production code.

| Resource | Type | Why It Helps |
|---|---|---|
| [Supabase JavaScript Client Reference](https://supabase.com/docs/reference/javascript/introduction) | Official docs | Complete reference for auth, queries, RPC, storage, realtime, and error handling. |
| [Supabase Server-Side Auth](https://supabase.com/docs/guides/auth/server-side) | Official docs | Canonical cookie-based SSR auth guidance for Next.js. |
| [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) | Official docs | Reference for writing secure policies behind snippets. |
| [Next.js Route Handlers](https://nextjs.org/docs/app/api-reference/file-conventions/route) | Official docs | Correct patterns for API routes in App Router. |
| [Next.js Proxy / Middleware](https://nextjs.org/docs/app/api-reference/file-conventions/proxy) | Official docs | Current Next.js request interception and protection model. |
| [Next.js Mutating Data](https://nextjs.org/docs/app/getting-started/mutating-data) | Official docs | Server Actions and form mutation patterns. |
| [supabase/supabase-js](https://github.com/supabase/supabase-js) | GitHub repo | Official JS client source and examples. |
| [supabase/ssr](https://github.com/supabase/ssr) | GitHub repo | Official SSR helpers used for modern Next.js auth snippets. |
| [supabase/auth-helpers](https://github.com/supabase/auth-helpers) | GitHub repo | Legacy auth helper reference, useful when maintaining older codebases. |
| [vercel/next.js with-supabase example](https://github.com/vercel/next.js/tree/canary/examples/with-supabase) | GitHub repo | Official example to compare snippet structure against. |
| [Zod](https://github.com/colinhacks/zod) | Production tool | Runtime validation for route handlers, forms, and Server Actions. |
| [shadcn/ui](https://github.com/shadcn-ui/ui) | Production tool | Useful component source for form and dashboard UI snippets. |
