-- RLS audit script for Supabase/PostgreSQL production environments.
-- Last verified: 2026-05-24

-- 1) List tables with and without RLS.
select
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
  and n.nspname = 'public'
order by c.relname;

-- 2) List all policies for quick diff/review.
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
order by tablename, policyname;

-- 3) Find tables with RLS enabled but no policies.
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

-- 4) Candidate tenant/user filter indexes (manual review recommended).
select
  t.relname as table_name,
  a.attname as column_name
from pg_class t
join pg_namespace n on n.oid = t.relnamespace
join pg_attribute a on a.attrelid = t.oid
where t.relkind = 'r'
  and n.nspname = 'public'
  and a.attnum > 0
  and not a.attisdropped
  and a.attname in ('tenant_id', 'team_id', 'workspace_id', 'user_id')
order by t.relname, a.attname;

-- 5) Optional: sample EXPLAIN template (edit table/column names).
-- explain analyze
-- select *
-- from public.projects
-- where tenant_id = 'replace-tenant-id';
