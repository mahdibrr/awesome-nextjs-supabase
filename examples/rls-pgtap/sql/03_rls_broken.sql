-- 03_rls_broken.sql
-- The BROKEN policies. Applying this file after 02_rls_fixed.sql
-- reproduces three of the incidents (001, 002, 005). run.sh / run.ps1
-- apply this during the "BROKEN demo" phase and expect those tests to
-- fail (and 002 to raise an infinite-recursion error).

BEGIN;

-- Drop the FIXED policies so the broken ones take effect.
DROP POLICY IF EXISTS posts_sel         ON posts;
DROP POLICY IF EXISTS posts_ins          ON posts;
DROP POLICY IF EXISTS posts_upd         ON posts;
DROP POLICY IF EXISTS objects_sel       ON example_objects;
DROP POLICY IF EXISTS objects_ins        ON example_objects;
DROP POLICY IF EXISTS posts_sel_broken  ON posts;
DROP POLICY IF EXISTS objects_sel_broken ON example_objects;

-- INC-002 / INC-003 bugs on `posts`:
-- We do NOT recreate the FIXED `posts_sel`. Instead we install the
-- self-referential `posts_sel_broken` below, so an authenticated query
-- on posts raises infinite recursion (INC-003). The pure "no SELECT
-- policy -> 0 rows" (INC-002) symptom is demonstrated cleanly in test
-- 001's anon case (anon has no SELECT policy at all -> count = 0).
CREATE POLICY posts_sel_broken ON posts
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM posts p2
      WHERE p2.id = posts.id
        AND p2.user_id = auth.uid()
    )
  );

-- INC-021 bug: unscoped/public object policy. USING (true) leaks every
-- owner's objects to any authenticated user.
CREATE POLICY objects_sel_broken ON example_objects
  FOR SELECT TO authenticated
  USING (true);

COMMIT;