-- 004_orm_role_bypass.test.sql
-- INC-018: a service_role with BYPASSRLS sees every row regardless of
-- policies. An ORM (Prisma, Drizzle, etc.) connected as service_role
-- therefore leaks all tenants. Only the `authenticated` role, carrying the
-- JWT, is scoped by the policies.

BEGIN;
-- pgTAP may install into the `pgtap` schema; make sure its functions are
-- on the search_path. A non-existent schema in search_path is ignored.
SET search_path = pgtap, public;
SELECT plan(3);

INSERT INTO tenants(id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'tenant-a'),
  ('22222222-2222-2222-2222-222222222222', 'tenant-b');

INSERT INTO posts(tenant_id, user_id, title, body) VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A1', 'body A1'),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A2', 'body A2'),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'A3', 'body A3'),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'B1', 'body B1'),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'B2', 'body B2');

-- service_role has BYPASSRLS: it sees all 5 rows, ignoring every policy.
SET LOCAL ROLE service_role;

SELECT is(
  (SELECT count(*)::int FROM posts),
  5,
  'INC-018: service_role (BYPASSRLS) sees all 5 rows across both tenants'
);

-- Authenticated user A: scoped to own 3 rows only.
SET LOCAL ROLE authenticated;
SELECT set_test_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

SELECT is(
  (SELECT count(*)::int FROM posts),
  3,
  'INC-018: authenticated user A is RLS-scoped to their own 3 rows'
);

-- And authenticated A cannot see B's rows by id.
SELECT is(
  (SELECT count(*)::int FROM posts WHERE user_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  0,
  'INC-018: authenticated user A cannot read user B''s rows'
);

SELECT * FROM finish();
ROLLBACK;