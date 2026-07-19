-- 002_recursion.test.sql
-- INC-003: a SELECT policy that EXISTS()s against the same table causes
-- infinite recursion at query time. The FIXED schema uses a direct
-- predicate (user_id = auth.uid()), so the query returns without error.
--
-- NOTE: run.sh / run.ps1 apply 03_rls_broken.sql and re-run the suite to
-- demonstrate that the broken self-referential policy
-- (`posts_sel_broken`) raises an infinite-recursion error here. This
-- file asserts the FIXED policy returns the right rows cleanly.

BEGIN;
-- pgTAP may install into the `pgtap` schema; make sure its functions are
-- on the search_path. A non-existent schema in search_path is ignored.
SET search_path = pgtap, public;
SELECT plan(2);

INSERT INTO tenants(id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'tenant-a');

INSERT INTO posts(tenant_id, user_id, title, body) VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A1', 'body A1'),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A2', 'body A2'),
  ('11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'B1', 'body B1');

SET LOCAL ROLE authenticated;
SELECT set_test_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- The fixed direct predicate does NOT recurse.
SELECT lives_ok(
  'SELECT * FROM posts',
  'INC-003 fixed: direct predicate (user_id = auth.uid()) returns without infinite recursion'
);

SELECT is(
  (SELECT count(*)::int FROM posts),
  2,
  'INC-003 fixed: user A sees exactly their 2 posts'
);

SELECT * FROM finish();
ROLLBACK;