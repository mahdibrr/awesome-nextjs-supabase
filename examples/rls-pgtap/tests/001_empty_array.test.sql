-- 001_empty_array.test.sql
-- INC-002: authenticated users see an empty array when RLS is enabled
-- but no SELECT policy exists. The FIXED schema (02_rls_fixed.sql)
-- provides a SELECT policy so user A sees A's rows. Anonymous users see
-- 0 rows (no anon policy at all).
--
-- NOTE: run.sh / run.ps1 re-run the suite after applying 03_rls_broken.sql.
-- Under the broken setup, `posts_sel_broken` (self-recursive) is active
-- instead of the fixed `posts_sel`, so the authenticated query below
-- raises an infinite-recursion error rather than returning 0. The pure
-- "no SELECT policy -> 0 rows" symptom (INC-002) is demonstrated by the
-- anon case in this file (anon has no SELECT policy at all -> count = 0).
-- This file asserts the FIXED behavior only.

BEGIN;
-- pgTAP may install into the `pgtap` schema; make sure its functions are
-- on the search_path. A non-existent schema in search_path is ignored.
SET search_path = pgtap, public;
SELECT plan(3);

-- Seed data as the table owner / superuser (no role switch yet).
INSERT INTO tenants(id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'tenant-a'),
  ('22222222-2222-2222-2222-222222222222', 'tenant-b');

INSERT INTO posts(tenant_id, user_id, title, body) VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A1', 'body A1'),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A2', 'body A2'),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'B1', 'body B1');

-- As authenticated user A: should see A's 2 posts.
SET LOCAL ROLE authenticated;
SELECT set_test_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

SELECT is(
  (SELECT count(*)::int FROM posts),
  2,
  'INC-002 fixed: authenticated user A sees their own 2 posts (not empty array)'
);

-- As anonymous: no anon SELECT policy -> 0 rows.
SET LOCAL ROLE anon;
SELECT set_config('request.jwt.claims', '', true);

SELECT is(
  (SELECT count(*)::int FROM posts),
  0,
  'INC-002: anon role has no SELECT policy -> 0 rows (empty array)'
);

-- Back to authenticated A, sanity check the count is still 2 after the
-- role flip (proves the empty-array symptom was role-specific, not a
-- side effect of the seed).
SET LOCAL ROLE authenticated;
SELECT set_test_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

SELECT is(
  (SELECT count(*)::int FROM posts),
  2,
  'INC-002 fixed: re-checking as A still returns 2'
);

SELECT * FROM finish();
ROLLBACK;