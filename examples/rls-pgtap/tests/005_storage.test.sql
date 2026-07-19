-- 005_storage.test.sql
-- INC-021: unscoped storage policies leak every owner's objects. The
-- FIXED schema scopes example_objects by owner_id = auth.uid() (a plain
-- stand-in for the real Supabase rule
-- `(storage.foldername(name))[1] = auth.uid()`).
--
-- NOTE: run.sh / run.ps1 apply 03_rls_broken.sql (objects_sel_broken
-- USING (true)) and re-run the suite to demonstrate that this test FAILS
-- under the broken setup (A would see all 3 objects). This file asserts
-- the FIXED behavior only.

BEGIN;
-- pgTAP may install into the `pgtap` schema; make sure its functions are
-- on the search_path. A non-existent schema in search_path is ignored.
SET search_path = pgtap, public;
SELECT plan(3);

INSERT INTO example_objects(bucket_id, name, owner_id) VALUES
  ('avatars', 'a/obj1.png', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('avatars', 'a/obj2.png', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('avatars', 'b/obj1.png', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

-- Authenticated user A: sees their own 2 objects only.
SET LOCAL ROLE authenticated;
SELECT set_test_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

SELECT is(
  (SELECT count(*)::int FROM example_objects),
  2,
  'INC-021 fixed: owner A sees exactly their 2 objects'
);

-- A cannot see B's object by id (returns 0 rows).
SELECT is(
  (SELECT count(*)::int FROM example_objects
    WHERE owner_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  0,
  'INC-021 fixed: A cannot read B''s objects'
);

-- Sanity: anon sees nothing (no anon policy).
SET LOCAL ROLE anon;
SELECT set_config('request.jwt.claims', '', true);

SELECT is(
  (SELECT count(*)::int FROM example_objects),
  0,
  'INC-021: anon role has no SELECT policy -> 0 objects'
);

SELECT * FROM finish();
ROLLBACK;