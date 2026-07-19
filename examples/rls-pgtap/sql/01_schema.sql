-- 01_schema.sql
-- Tables for the RLS / pgTAP example. No FK to auth.users (that relation
-- does not exist on plain postgres); profiles.id is just a uuid the user
-- owns. RLS is ENABLED but not FORCED, so the table owner / superuser can
-- still seed data during setup. Tests switch role to `authenticated` to
-- trigger RLS.

BEGIN;

CREATE TABLE IF NOT EXISTS tenants (
  id   uuid PRIMARY KEY,
  name text NOT NULL
);

-- profiles stand in for Supabase auth.users rows (id = the user's uuid).
CREATE TABLE IF NOT EXISTS profiles (
  id        uuid PRIMARY KEY,
  full_name text NOT NULL
);

CREATE TABLE IF NOT EXISTS posts (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id     uuid        NOT NULL,
  title       text        NOT NULL,
  body        text        NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS example_objects (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id   text       NOT NULL,
  name        text       NOT NULL,
  owner_id    uuid,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- RLS enabled (not forced). Owner/superuser still sees everything, so
-- tests can seed data before switching role.
ALTER TABLE posts          ENABLE ROW LEVEL SECURITY;
ALTER TABLE example_objects ENABLE ROW LEVEL SECURITY;

-- Table privileges. RLS policies only filter rows; they do NOT grant
-- table-level access. Supabase grants these to anon/authenticated/service
-- automatically; we replicate that here so the roles can actually SELECT.
GRANT SELECT, INSERT, UPDATE, DELETE ON posts          TO authenticated;
GRANT SELECT                                    ON posts          TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON posts          TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON example_objects TO authenticated;
GRANT SELECT                                    ON example_objects TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON example_objects TO service_role;

COMMIT;