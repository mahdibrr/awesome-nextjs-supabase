-- 02_rls_fixed.sql
-- The CORRECTED policies. Applying this file makes every pgTAP test pass.

BEGIN;

-- Tidy: drop any broken policies from a previous run so this file is
-- idempotent.
DROP POLICY IF EXISTS posts_sel         ON posts;
DROP POLICY IF EXISTS posts_sel_broken  ON posts;
DROP POLICY IF EXISTS posts_ins         ON posts;
DROP POLICY IF EXISTS posts_upd         ON posts;
DROP POLICY IF EXISTS objects_sel         ON example_objects;
DROP POLICY IF EXISTS objects_sel_broken  ON example_objects;
DROP POLICY IF EXISTS objects_ins         ON example_objects;

-- INC-002 / INC-018 fix: scoped SELECT/INSERT/UPDATE by owner.
-- Authenticated users only ever see/touch rows where user_id = auth.uid().
CREATE POLICY posts_sel ON posts
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY posts_ins ON posts
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY posts_upd ON posts
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- INC-015 fix: supporting index so the user_id predicate resolves via an
-- Index Scan instead of a Seq Scan.
CREATE INDEX IF NOT EXISTS posts_user_idx ON posts(user_id);

-- INC-003 fix: direct predicate, NO self-referential EXISTS() on the same
-- table. The SELECT policy above is already the direct form; nothing extra
-- to add here. The broken file (03_rls_broken.sql) shows the recursive
-- version that fails.

-- INC-021 fix: owner-scoped objects. Mirrors the real Supabase rule
--   (storage.foldername(name))[1] = auth.uid()
-- using a plain owner_id column for clarity.
CREATE POLICY objects_sel ON example_objects
  FOR SELECT TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY objects_ins ON example_objects
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

COMMIT;