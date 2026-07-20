-- 003_latency_index.test.sql
-- INC-015: an RLS predicate on an unindexed column forces a Seq Scan.
-- The FIXED schema adds posts_user_idx so the (user_id = auth.uid())
-- predicate resolves via an Index Scan. To make the planner actually
-- prefer the index, the predicate must be SELECTIVE: we give user A a
-- single post, then spread 500 posts across 500 distinct other users.
-- Querying for A's user_id then matches 1 of 501 rows -> Index Scan.

BEGIN;
-- pgTAP may install into the `pgtap` schema; make sure its functions are
-- on the search_path. A non-existent schema in search_path is ignored.
SET search_path = pgtap, public;
SELECT plan(2);

INSERT INTO tenants(id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'tenant-a'),
  ('22222222-2222-2222-2222-222222222222', 'tenant-b');

-- 1 post for A.
INSERT INTO posts(tenant_id, user_id, title, body) VALUES
  ('11111111-1111-1111-1111-111111111111',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'A1', 'body A1');

-- 500 posts, each owned by a DISTINCT user_id, so that the predicate
-- `user_id = A` is highly selective (1 of 501).
INSERT INTO posts(tenant_id, user_id, title, body)
SELECT '22222222-2222-2222-2222-222222222222',
       ('00000000-0000-0000-0000-' || lpad(g::text, 12, '0'))::uuid,
       'X-' || g, 'body ' || g
FROM generate_series(1, 500) g;

ANALYZE posts;

-- Act as authenticated user A.
SET LOCAL ROLE authenticated;
SELECT set_test_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Capture the EXPLAIN text via a temp table.
CREATE TEMP TABLE explain_out(plan_text text);

DO $$
DECLARE
  line text;
  plan_text text := '';
BEGIN
  FOR line IN
    EXECUTE format(
      'EXPLAIN (FORMAT TEXT) SELECT * FROM posts WHERE user_id = %L::uuid',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
    )
  LOOP
    plan_text := plan_text || line || E'\n';
  END LOOP;
  INSERT INTO explain_out VALUES (plan_text);
END $$;

-- Primary, deterministic assertion: NOT a Seq Scan.
SELECT is(
  (SELECT NOT (plan_text ~* 'Seq Scan') FROM explain_out),
  true,
  'INC-015 fixed: planner does NOT use a Seq Scan with the index present'
);

-- Strong secondary assertion: an Index Scan is chosen.
SELECT is(
  (SELECT plan_text ~* 'Index Scan' OR plan_text ~* 'Index Only Scan' FROM explain_out),
  true,
  'INC-015 fixed: planner uses an Index Scan (or Index Only Scan) on posts_user_idx'
);

SELECT * FROM finish();
ROLLBACK;