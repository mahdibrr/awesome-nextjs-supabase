# INC-002: Supabase returns an empty array even though rows exist

Last verified: 2026-07-19

## Symptom

You seed `posts` (or any tenant table) and confirm the rows are there. In the Supabase Studio SQL editor you run `select * from public.posts;` and see every row. Then you ship the app, and `supabase.from('posts').select()` returns `[]`. No error, no exception, no log line. The build is green. Real users stare at an empty dashboard.

The "it works on localhost" trap fires here: local dev often uses the `service_role` key (or a permissive `anon` policy that was later tightened), so the bug only surfaces in a deployed environment using the real `authenticated` client.

## Impact

Silent data invisibility. No exception is thrown, so observability that watches for errors stays quiet — the failure can ride along in production for days. Users see empty lists, dashboards, and workspaces; trust erodes. Because the cause is a missing policy (not a syntax error), rollbacks and redeploys do nothing — the table is structurally invisible to the role your app is using.

## Root cause

RLS is enabled on the table but **no `select` policy matches the `authenticated` (or `anon`) role**. With RLS on and zero matching policies, Postgres returns an empty result set — it does not error, because "no rows visible to this role" is a valid answer.

Role hierarchy, the part that bites:

- `service_role` carries `BYPASSRLS`. The Supabase Studio SQL editor, your seed scripts, and anything using the `service_role` key skip policy evaluation entirely and see every row. That is why Studio and seed scripts "work" while the app doesn't.
- `anon` and `authenticated` are subject to RLS policies. No matching `for select` policy for that role = empty array.

For the full path from request to empty result, see [RLS Request Flow](../diagrams/rls-request-flow.md): JWT → `auth.uid()` → `USING`/`WITH CHECK` → rows returned (or `[]`).

## Detection (run these now)

Run these against your database. Each is copied from [rls-audit.sql](../sql/rls-audit.sql) so you can paste straight into Studio or psql.

### Query 1 — Tables with RLS enabled but no policies

```sql
with rls_tables as (
  select c.oid, c.relname
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind = 'r'
    and n.nspname = 'public'
    and c.relrowsecurity = true
)
select r.relname as table_with_rls_no_policy
from rls_tables r
left join pg_policies p
  on p.tablename = r.relname
 and p.schemaname = 'public'
where p.policyname is null
order by r.relname;
```

- **Expected (healthy):** zero rows, or only tables you intentionally lock down.
- **Actual (incident):** `posts` (or your offending table) is returned. This is the smoking gun — RLS is on, and no policy exists for any role.

### Query 2 — All policies on the offending table

```sql
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
  and tablename = 'posts'
order by policyname;
```

- **Expected (healthy):** at least one row with `cmd = 'select'` and `roles` containing `authenticated` (or `anon`), with a `qual` predicate that scopes rows to the user.
- **Actual (incident):** empty result, or rows only for `cmd in ('insert','update','delete')` with no `select` policy. The app's read path has no policy to match.

### Query 3 — Confirm RLS is actually enabled on the table

```sql
select
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
  and n.nspname = 'public'
  and c.relname = 'posts';
```

- **Expected (healthy):** `rls_enabled = true` **and** Query 1 does not return this table.
- **Actual (incident):** `rls_enabled = true` and Query 1 returns `posts`. That combination — RLS on, no `select` policy — is the root cause.

## Fix

Add a scoped `select` policy for the role your app actually uses. Concrete example for a tenant-scoped table:

```sql
create policy "tenanted select"
  on public.posts
  for select
  to authenticated
  using (auth.uid() = user_id);
```

For a broader "any authenticated user can read" case (e.g. a public catalog), scope it explicitly — do not reach for `anon` unless the data is truly public:

```sql
create policy "authenticated can read posts"
  on public.posts
  for select
  to authenticated
  using (true);
```

### The critical step: test as the real authenticated user

Never validate RLS with the `service_role` key — it bypasses policies, so a passing test tells you nothing. Use the user's access token.

Two-line Supabase client pattern (browser / SSR):

```ts
// After the user signs in, you already have their access_token in the session.
await supabase.auth.setSession({
  access_token: userAccessToken,
  refresh_token: userRefreshToken,
});
const { data, error } = await supabase.from('posts').select('*');
// data must now contain the user's rows; error must be null.
```

psql-as-role verification (Supabase supports `set role`):

```sql
-- Drop to the authenticated role, inject the JWT claim, re-run the query.
set request.jwt.claim.sub = '<user-uuid>';
set role authenticated;
select * from public.posts;  -- expect the user's rows, not []
reset role;
```

Or with pgTAP in CI:

```sql
select tests.run(
  'authenticated user sees their own posts',
  select is(
    'select count(*) from public.posts',
    select count(*) from public.posts where user_id = '<user-uuid>',
    'RLS select policy scopes posts to owner'
  )
);
```

Only mark the incident resolved once the read returns rows when run with the user's token and `[]` when run as a different user.

## Prevention

A CI-runnable SQL check that fails the build when any table has RLS enabled but zero `select` policies for `authenticated`. Empty result = pass; any row = fail.

```sql
-- rls-select-policy-gate.sql
-- Returns offending tables. Empty result = pass.
with rls_tables as (
  select c.relname
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind = 'r'
    and n.nspname = 'public'
    and c.relrowsecurity = true
)
select r.relname as rls_enabled_no_authenticated_select_policy
from rls_tables r
where not exists (
  select 1
  from pg_policies p
  where p.schemaname = 'public'
    and p.tablename = r.relname
    and p.cmd = 'select'
    and (p.roles = '{authenticated}' or p.roles = '{authenticated, anon}' or p.roles = '{public}')
)
order by r.relname;
```

Wire it in one of two ways:

1. **pgTAP test** — add to your RLS test suite: `select ok(count(*) = 0, 'no RLS-enabled table lacks an authenticated select policy') from ( …query… ) g;`
2. **Audit gate** — append it as Query 6 in [rls-audit.sql](../sql/rls-audit.sql) and run `rls-audit.sql` against the preview branch in CI; fail the pipeline if any row is returned.

Also enforce in code review: any migration that adds `alter table … enable row level security` must ship in the same PR as the `create policy … for select to authenticated …` policy. Add a PR checklist line: "RLS enabled? Select policy for `authenticated` included and tested with a real user token?"

## References

- Supabase RLS docs: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase: testing policies as the real user: https://supabase.com/docs/guides/database/postgres/row-level-security#testing-policies
- [RLS Audit SQL](../sql/rls-audit.sql)
- [RLS Request Flow](../diagrams/rls-request-flow.md)