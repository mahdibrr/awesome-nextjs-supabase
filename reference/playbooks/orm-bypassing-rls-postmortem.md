# INC-018: ORM (Prisma/Drizzle) bypassing Supabase RLS via service_role / direct connection

Last verified: 2026-07-19

> Companion to [RLS empty-array postmortem](../playbooks/rls-empty-array-postmortem.md) (INC-002, "no rows visible") and [RLS audit SQL](../sql/rls-audit.sql). This incident is the opposite failure: the policies are correct *and* rows are visible — just to the wrong tenant. Where INC-002 is "RLS on, no `select` policy → empty array," INC-018 is "RLS on, correct policy, but the ORM connection never assumes the user's role → all rows returned."

## Symptom

A team ships RLS policies on every tenant table. They test with the Supabase JS client (`supabase.from('posts').select()`) using the user's session token, watch tenant A see only tenant A's rows, and call it done. Then they move the server-side reads/writes to **Prisma** or **Drizzle** for type safety — and a tenant suddenly sees **another tenant's rows**, or RLS appears to "not apply at all." The policies still look correct in Studio. `pg_policies` shows exactly the scoped `using (auth.uid() = user_id)` clause they wrote. The ORM queries return everything.

The "it works with `supabase-js`" trap fires here: the JS client carries the user's JWT, so PostgREST sets the `authenticated` role and `request.jwt.claims` per request, and policies are enforced. The ORM does none of that. The ORM opens a fixed Postgres connection with a fixed role, and that role is almost always `service_role` or `postgres` — both of which carry `BYPASSRLS`. Policies are silently inert for every server-side ORM query.

## Impact

**Cross-tenant data leak — the highest-severity class of bug in a multi-tenant SaaS.** No exception is thrown; observability that watches for errors stays quiet. The leak rides along in production until a customer pastes a screenshot of someone else's data into support. Worse, writes are also unscoped: `prisma.post.create({ data: { tenant_id: 'other-tenant' } })` succeeds because no `WITH CHECK` policy is evaluated for a `BYPASSRLS` role. One bad payload and you have corrupted tenant ownership with no audit trail in your RLS policies.

Because the cause is the connection role — not a policy bug — no amount of policy tightening, redeploys, or rollbacks will fix it. The fix is architectural: either stop using the ORM for tenant-scoped queries, or make the ORM assume the user's role per request.

## Root cause — four distinct causes, each with a minimal repro

### Cause 1 — The ORM connects with `service_role` (or any `BYPASSRLS` role)

`service_role` is a Postgres role with the `BYPASSRLS` attribute. Supabase's own docs state it plainly: *"Secret keys authorize access to your project's data via the built-in `service_role` Postgres role. By design, this role has full access to your project's data. It also uses the `BYPASSRLS` attribute, skipping any and all Row Level Security policies you attach."* PostgreSQL itself confirms the mechanism: *"Superusers and roles with the `BYPASSRLS` attribute always bypass the row security system when accessing a table."*

A Prisma `DATABASE_URL` or a Drizzle connection string built from the Supabase dashboard's "service role" / `postgres` connection string puts every ORM query on a `BYPASSRLS` connection. Policies are not "failing" — they are never evaluated.

Repro (Prisma):

```prisma
// prisma/schema.prisma  — the trap is in env, not schema
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")   // ← built from the service_role / postgres connection string
  directUrl = env("DIRECT_URL")
}
```

```ts
// lib/db.ts
import { PrismaClient } from '@prisma/client'
export const prisma = new PrismaClient()

// app/posts/page.tsx — Server Component, tenant A logged in
const posts = await prisma.post.findMany()
// expected: tenant A's posts
// actual: every tenant's posts — RLS never evaluated because the connection role is service_role
```

Repro (Drizzle):

```ts
// lib/db.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

// URL built from the Supabase "postgres" (service_role) connection string
const client = postgres(process.env.DATABASE_URL!, { prepare: false })
export const db = drizzle(client)

// app/posts/page.tsx — tenant A logged in
const posts = await db.select().from(postsTable)
// expected: tenant A's posts
// actual: every tenant's posts
```

### Cause 2 — RLS is enforced by the connection's ROLE, not the JWT, unless you set it per request

RLS is a Postgres feature, not a Supabase-JS feature. Postgres evaluates policies against `current_user` (the active role) and the `request.jwt.claims` config GUC. The Supabase JS client works because PostgREST, on every request, runs `set role authenticated; set_config('request.jwt.claims', '<jwt>', true)` against a low-privilege `authenticator` connection before executing the query. An ORM does none of this. It uses whatever role the connection string authenticates as, for the lifetime of the connection. The user's JWT is never injected.

So even if you switch the ORM's connection string away from `service_role` to a custom role that is **subject** to RLS, you still have a fixed role with no per-request JWT — `auth.uid()` returns NULL inside policies (because `request.jwt.claims` is empty), and policies written as `using (auth.uid() = user_id)` match zero rows... or, worse, if you wrote `using (true)` "temporarily for testing," every row is visible to that role across all tenants.

Repro — confirm the GUC is empty on the ORM connection:

```ts
// Drizzle
const result = await db.execute(sql`
  select current_user, current_setting('request.jwt.claims', true) as jwt_claims
`)
console.log(result)
// healthy (supabase-js path):  current_user = authenticated, jwt_claims = '{"sub":"<user-uuid>",...}'
// incident (ORM path):          current_user = service_role (or postgres), jwt_claims = '' (or NULL)
```

### Cause 3 — Confusing "RLS at the data layer" with "the ORM will enforce it"

This is the conceptual error that makes causes 1 and 2 invisible. ORMs do not enforce RLS. **Postgres** does, and only for the right role. The Supabase Prisma guide hints at this: *"If you plan to solely use Prisma instead of the Supabase Data API (PostgREST), turn it off in the API Settings."* Translated: Prisma connects straight to Postgres; it does not go through PostgREST, it does not receive the per-request JWT/role swap that `supabase-js` gets you. RLS policies are inert in a Prisma/Drizzle code path unless **you** inject the user's JWT and `set local role authenticated` per request (see Cause 2 and the Fix).

The same is true on the Drizzle side — the Supabase Drizzle guide covers connection setup and `prepare: false`, but says nothing about RLS, the `service_role` key, or per-request role switching. RLS enforcement via Drizzle requires the wrapper pattern from Drizzle's own RLS docs, not just a connection string.

Repro — the silent-inert test that gives false confidence:

```sql
-- Run in Supabase Studio (uses service_role, BYPASSRLS):
select * from public.posts where tenant_id = 'tenant-a';
-- returns tenant-a rows. Test passes. Proves nothing about RLS.

-- Run via the app's supabase-js client as tenant A's user:
select * from public.posts;  -- (via supabase.from('posts').select())
-- returns tenant-a rows. Test passes. Still proves nothing about the ORM path.

-- Run via the ORM (Prisma/Drizzle) with the service_role connection string:
-- (prisma.post.findMany() / db.select().from(posts))
-- returns ALL tenants' rows. This is the test nobody ran.
```

### Cause 4 — `directUrl` (migrations) vs `url` (runtime) misconfigured

Prisma distinguishes `url` (runtime, Prisma Client) from `directUrl` (CLI: `prisma migrate deploy`, `db push`, introspection, Studio). The classic mistake is pointing `directUrl` at the **direct, non-pooled** connection — which on Supabase is the `postgres`/`service_role` credential on port 5432 — and then, through a copy-paste or a swapped `.env`, pointing `url` at the same string. Now runtime queries ride a `BYPASSRLS`, non-pooled connection. Worse: in Prisma ORM v7, `directUrl` was **removed from the schema** and moved into `prisma.config.ts`; the docs recommend pointing `datasource.url` in the config at the direct URL for CLI use. If the runtime driver adapter is accidentally pointed at the same direct URL, every runtime query is a service-role query.

Repro — the swapped-`.env` failure:

```env
# .env  — wrong: runtime (DATABASE_URL) points at the service-role direct connection
DATABASE_URL="postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres"
DIRECT_URL="postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres"

# correct (for the "ORM only for admin paths" choice — see Fix):
# DATABASE_URL → a custom prisma role with bypassrls, used only for migrations/admin
# runtime tenant-scoped reads → go through supabase-js, NOT Prisma
```

```ts
// lib/db.ts — driver adapter picks up the swapped DATABASE_URL
import { PrismaPg } from '@prisma/adapter-pg'
const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL }) // ← service_role
export const prisma = new PrismaClient({ adapter })
// every prisma query now bypasses RLS
```

## Detection (run these now)

### Query 1 — What role is the ORM connection actually using?

Run this **through the ORM** (a Drizzle `db.execute` or a Prisma `$queryRaw`), not through Studio:

```sql
select
  current_user                as active_role,
  current_setting('request.jwt.claims', true) as jwt_claims,
  current_setting('request.jwt.claim.sub', true) as jwt_sub,
  (select rolbypassrls from pg_roles where rolname = current_user) as bypass_rls;
```

- **Expected (healthy, ORM-with-per-request-role choice):** `active_role = authenticated`, `jwt_claims` is the user's JWT JSON, `jwt_sub` is the user's UUID, `bypass_rls = false`.
- **Actual (incident):** `active_role = service_role` (or `postgres`, or a custom role with `bypass_rls = true`), `jwt_claims` is empty/NULL, `jwt_sub` is empty. This is the smoking gun — a `BYPASSRLS` role with no JWT.

### Query 2 — Which of my ORM connections have BYPASSRLS?

```sql
-- list roles the ORM could authenticate as that skip RLS
select rolname, rolbypassrls, rolsuper
from pg_roles
where rolbypassrls = true or rolsuper = true
order by rolname;
```

- **Expected (healthy):** only roles you intentionally use for admin/migrations (`service_role`, `postgres`, a dedicated `prisma` migration role), and your ORM's runtime connection is **not** in this list.
- **Actual (incident):** the role your ORM runtime connection authenticates as appears here. If `bypass_rls = true` for the role in Query 1, RLS is provably inert on that path.

### Query 3 — Reproduce the cross-tenant leak through the actual app path

This is the test that actually proves the bug. Log in as tenant A's user through the real app, hit a route that runs an ORM read, and assert tenant B's rows are not returned.

```ts
// tests/orm-rls-leak.test.ts (pseudo-test, run against a staging DB seeded with two tenants)
import { prisma } from '@/lib/db'
import { createClient } from '@supabase/supabase-js'

test('ORM read as tenant A must not return tenant B rows', async () => {
  // seed: tenant A user, tenant B user, one post each
  // sign in as tenant A's user, get their session token
  const supabase = createClient(url, anonKey)
  await supabase.auth.setSession({ access_token: tenantASession, refresh_token: tenantARefresh })

  // the actual app path — Prisma read, no per-request role swap
  const rows = await prisma.post.findMany()

  const leaked = rows.filter((r) => r.tenant_id === TENANT_B_ID)
  expect(leaked).toHaveLength(0)   // incident: fails — leaked.length > 0
})
```

- **Expected (healthy):** `leaked` is empty; tenant A sees only tenant A's rows.
- **Actual (incident):** `leaked` contains tenant B's rows — the cross-tenant leak, reproduced through the real code path.

For the comparison, run the same scenario through `supabase-js` — it will pass. The delta between "passes with `supabase-js`, fails with ORM" is the entire incident.

## Fix — pick an architecture deliberately, do not stumble into one

There are three legitimate choices. The bug is not picking any of them and ending up with "ORM on `service_role`" by accident.

### Choice A — `supabase-js` for everything that must respect RLS; ORM only for migrations / admin / privileged paths

The simplest and safest choice. Keep using `supabase.from('posts').select()` (or the SSR client) for any tenant-scoped read or write — it carries the user's JWT, PostgREST sets `authenticated` + `request.jwt.claims` per request, and your policies are enforced exactly as written. Use Prisma/Drizzle only for: schema migrations, backfills, background jobs that legitimately need full access, and admin tooling. For those, connect with a dedicated role and accept that it bypasses RLS by design.

Trade-off: you give up type-safe ORM queries on the tenant-scoped path. Many teams find that an acceptable price; you keep the strongest RLS guarantee Postgres offers, with zero per-request plumbing.

```ts
// app/posts/page.tsx — tenant-scoped read goes through supabase-js, NOT Prisma
import { createServerClient } from '@supabase/supabase-js'
const supabase = createServerClient(url, anonKey, { global: { headers: { Authorization: `Bearer ${userJwt}` } } })
const { data: posts } = await supabase.from('posts').select('*')   // RLS enforced

// lib/db.ts — Prisma with a dedicated role, used only for migrations/admin, never for tenant reads
import { PrismaClient } from '@prisma/client'
export const prisma = new PrismaClient()  // connection: a prisma role with bypassrls, by design
```

### Choice B — ORM for tenant-scoped queries, but set the Postgres role per request from the user's JWT

Use this when the team genuinely wants ORM ergonomics on the tenant-scoped path. You must, on every request, inside a transaction, inject the user's JWT and switch the role before running queries, then reset. Drizzle's own RLS docs ship the canonical wrapper:

```ts
// adapted from https://orm.drizzle.team/docs/rls  (Drizzle SupaSecureSlack example)
import { sql } from 'drizzle-orm'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

export function createDrizzle(token: { sub?: string; role?: string }, { admin, client }) {
  return {
    admin,
    rls: (async (transaction, ...rest) => {
      return await client.transaction(async (tx) => {
        try {
          await tx.execute(sql`
            select set_config('request.jwt.claims', '${sql.raw(JSON.stringify(token))}', TRUE);
            select set_config('request.jwt.claim.sub', '${sql.raw(token.sub ?? '')}', TRUE);
            set local role ${sql.raw(token.role ?? 'anon')};
          `)
          return await transaction(tx)
        } finally {
          await tx.execute(sql`
            select set_config('request.jwt.claims', NULL, TRUE);
            select set_config('request.jwt.claim.sub', NULL, TRUE);
            reset role;
          `)
        }
      })
    }) as typeof client.transaction,
  }
}

// usage — every tenant-scoped query MUST go through db.rls, never db directly
const db = createDrizzle(decodedJwt, { admin, client })
const posts = await db.rls((tx) => tx.select().from(postsTable))
```

Pitfalls (all load-bearing, all documented in community + Drizzle issue #594):

- **Connection pooling breaks `set local`.** `set local` only persists for the duration of a transaction. You must run on a **session-mode** pooler (Supabase session pooler, port 5432) or a direct connection — transaction-mode poolers (port 6543) can reuse the connection across requests and leak the role between tenants. Several teams have reported the role persisting across pooled requests; the `finally { reset role }` is mandatory, not optional.
- **Transaction-mode pooler required `prepare: false`.** Supabase's transaction pooler does not support prepared statements; without `prepare: false` you hit "prepared statement already exists."
- **Forgetting the wrapper = silent RLS bypass.** Any query written as `db.select()` instead of `db.rls((tx) => ...)` runs as the connection's default role — usually `service_role`. The wrapper is a footgun: a single missed call re-opens the leak.
- **Best practice from the Drizzle community:** connect with the low-privilege `authenticator` role (the same role PostgREST uses), not `postgres`, so that even if the wrapper is forgotten, RLS is still enforced (the connection's default role is subject to RLS, not `BYPASSRLS`). This converts "forgot the wrapper = data leak" into "forgot the wrapper = empty result," which is loud instead of silent.

Trade-off: you get ORM ergonomics on the tenant path, at the cost of a wrapper every query must use, pooler-mode constraints, and a per-request transaction. The wrapper is the kind of thing a single PR can forget in one new query — which is exactly why the Prevention section below exists.

### Choice C — `service_role` server-side + application-layer authorization, RLS deliberately skipped for ORM-managed tables

A valid, common, and deliberate choice. You accept that the ORM runs on a `BYPASSRLS` connection, you disable RLS (or scope policies to `anon`/`authenticated` for the PostgREST path only) on ORM-managed tables, and you enforce tenant isolation in your application code: every query takes a `tenantId` from the authenticated session, every `where` clause includes `tenant_id = ?`, and a middleware/server-action guard rejects mismatches before the query runs.

This is legitimate **only if** it is an explicit decision with a review checklist, a test that proves a forged `tenantId` is rejected, and a convention that is enforced in code review. The incident in this postmortem is **not** Choice C — it is a team that thought they had RLS protection and did not. The difference between "deliberate Choice C" and "incident" is whether the team knows the ORM bypasses RLS.

Trade-off: you own tenant isolation in app code. You lose the database-level guarantee that a forgotten `where tenant_id = ?` cannot leak across tenants — instead, a forgotten `where` *will* leak, and only your test suite catches it.

### Decision matrix

| Situation | Use |
| --- | --- |
| Tenant-scoped reads/writes, you want the strongest guarantee with zero plumbing | **Choice A** — `supabase-js` for tenant paths, ORM for migrations/admin only |
| You want ORM ergonomics on the tenant path and are willing to maintain the wrapper | **Choice B** — Drizzle `createDrizzle` / Prisma equivalent, connect as `authenticator`, `set local role authenticated` + JWT claims per request, `prepare: false`, session-mode pooler |
| You have a strong app-layer authz model and want ORM everywhere with no RLS on ORM tables | **Choice C** — `service_role` ORM, RLS disabled on ORM tables, app enforces `tenant_id`, with a test that a forged `tenantId` is rejected |
| You currently have `service_role` in `DATABASE_URL` and "think RLS is on" | **Neither — you have the incident.** Apply Choice A immediately, then decide B vs C deliberately |

## Prevention

### CI gate — assert the ORM runtime role is not `BYPASSRLS` for tenant tables

Append this to [rls-audit.sql](../sql/rls-audit.sql) and run it against the preview branch in CI, executing it **through the ORM** (so `current_user` reflects the ORM's actual connection role):

```sql
-- orm-role-bypass-gate.sql
-- Returns rows when the ORM's active role can bypass RLS on tenant tables. Empty = pass.
with tenant_tables as (
  select c.relname
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind = 'r'
    and n.nspname = 'public'
    and c.relrowsecurity = true
    and exists (
      select 1 from pg_attribute a
      where a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
        and a.attname in ('tenant_id', 'team_id', 'workspace_id', 'user_id')
    )
)
select
  current_user                       as orm_active_role,
  (select rolbypassrls from pg_roles where rolname = current_user) as bypass_rls,
  array_agg(t.relname)               as tenant_tables_at_risk
from tenant_tables t
where (select rolbypassrls from pg_roles where rolname = current_user) = true
group by current_user;
-- Pass: zero rows (the ORM's role does not have BYPASSRLS on tenant tables).
-- Fail: any row (the ORM's role bypasses RLS — Choice A is broken; Choice B's wrapper was not applied; Choice C must be explicit).
```

Wire it two ways:

1. **pgTAP** — `select ok(count(*) = 0, 'ORM runtime role must not have BYPASSRLS on tenant tables') from ( …query… ) g;` run through the ORM in CI.
2. **Audit gate** — append as Query 6 in [rls-audit.sql](../sql/rls-audit.sql) and run against the preview branch; fail the pipeline on any row.

### pgTAP — assert tenant B is invisible through the actual app path

This is the test that catches Choice B's "forgot the wrapper" regression and Choice A's "someone added a Prisma read on a tenant route" regression. It runs the real ORM query as tenant A and asserts tenant B's rows are absent.

```sql
-- tests/orm_rls_isolation.sql (pgTAP, run via supabase test db)
-- Seed: two tenants, one post each.
-- The test harness signs in as tenant A's user, then calls the app's ORM read path,
-- which must route through db.rls(...) (Choice B) or supabase-js (Choice A).

select tests.run('ORM read as tenant A does not leak tenant B rows',
  select is(
    (select count(*) from public.posts where tenant_id = :'tenant_b_id'
     -- this query is executed through the app's ORM read path, not raw SQL
     -- for Choice B: wrapped in db.rls((tx) => tx.select().from(posts))
     -- for Choice A: replaced by supabase.from('posts').select() filtered to tenant B
    )::int,
    0,
    'tenant B rows must be invisible to tenant A through the ORM path'
  )
);
```

### Code review checklist

Add to the PR template:

- "Does this PR add a tenant-scoped read/write through Prisma or Drizzle? If yes: which choice (A/B/C) applies, and where is the proof (Query 1 output, pgTAP result)?"
- "If Choice B: is every tenant-scoped query wrapped in `db.rls(...)`? Grep for `db.select()` / `prisma.*findMany` outside the wrapper — any hit is a bug."
- "If Choice A: is this Prisma/Drizzle query restricted to migrations/admin/privileged paths? Tenant-scoped reads must go through `supabase-js`."
- "Is `DATABASE_URL` (runtime) distinct from `DIRECT_URL` (CLI), and does the runtime URL point at a role **without** BYPASSRLS (Choice B) or to a deliberately-privileged role (Choice A/C)?"

## References

- Supabase Row Level Security (Bypassing RLS, service keys) — https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase Postgres Roles (`service_role` bypasses RLS) — https://supabase.com/docs/guides/database/postgres/roles
- Supabase Understanding API Keys (service_role / BYPASSRLS) — https://supabase.com/docs/guides/getting-started/api-keys
- Supabase Custom Claims and RBAC — https://supabase.com/docs/guides/database/postgres/custom-claims-and-role-based-access-control-rbac
- Supabase Database Testing (pgTAP for RLS) — https://supabase.com/docs/guides/database/testing
- Supabase + Prisma guide (notes Prisma replaces PostgREST; `bypassrls` on the prisma user) — https://supabase.com/docs/guides/database/prisma
- Prisma + Supabase guide (pooler, `directUrl`, no RLS discussion) — https://www.prisma.io/docs/orm/v6/overview/databases/supabase
- Prisma Connection URLs reference (`url` vs `directUrl`) — https://www.prisma.io/docs/orm/reference/connection-urls
- Supabase + Drizzle guide (pooler, `prepare: false`; no RLS discussion) — https://supabase.com/docs/guides/database/drizzle
- Drizzle ORM Row-Level Security docs (`createDrizzle` wrapper, `set_config('request.jwt.claims')`, `set local role`) — https://orm.drizzle.team/docs/rls
- PostgreSQL Row Security Policies (BYPASSRLS attribute; policies run with the active role's privileges) — https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- [RLS empty-array postmortem](../playbooks/rls-empty-array-postmortem.md) — INC-002, the opposite symptom
- [RLS audit SQL](../sql/rls-audit.sql)