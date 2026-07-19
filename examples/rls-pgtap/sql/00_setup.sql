-- 00_setup.sql
-- Roles mirroring Supabase, an auth.uid() mock driven by the
-- request.jwt.claims GUC, and a helper to switch "current user" inside
-- a test transaction. Runs on plain PostgreSQL + pgTAP (no Supabase needed).

-- pgTAP extension (CI creates it beforehand; locally this is a no-op if
-- already present). Wrapped so a duplicate or preloaded-shared-lib form
-- does not abort the run.
DO $$
BEGIN
  BEGIN
    CREATE EXTENSION IF NOT EXISTS pgtap;
  EXCEPTION WHEN feature_not_enabled THEN
    -- pgtap may be a preloaded shared library in some CI images; skip.
    NULL;
  END;
END $$;

-- Supabase-style roles. service_role carries BYPASSRLS (matches Supabase).
DO $$ BEGIN CREATE ROLE anon; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE authenticated; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE service_role WITH BYPASSRLS; EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- auth schema + uid() mock. Reads the same GUC Supabase's auth.uid() reads:
-- request.jwt.claims. Returns the `sub` claim, or NULL when unset.
CREATE SCHEMA IF NOT EXISTS auth;

CREATE OR REPLACE FUNCTION auth.uid() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'
$$;

-- Helper to act as a specific authenticated user inside the current
-- transaction. set_config(..., true) scopes the GUC to the transaction,
-- which is exactly what we want under pgTAP (each test file is wrapped in
-- a transaction by pg_prove). Created in `public` explicitly so its
-- location does not depend on the search_path at setup time.
CREATE OR REPLACE FUNCTION public.set_test_user(p_uid UUID) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  PERFORM set_config(
    'request.jwt.claims',
    json_build_object('sub', p_uid, 'role', 'authenticated')::text,
    true  -- local to the transaction
  );
END $$;