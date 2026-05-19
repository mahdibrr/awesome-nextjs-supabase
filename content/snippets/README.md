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
