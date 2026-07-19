# INC-021: Storage uploads succeed but private files leak (or uploads 403)

Last verified: 2026-07-19
Pinned to: Supabase Storage (current docs as of July 2026 — `owner_id` is the canonical column; the legacy `owner` column is deprecated). Next.js App Router for the server-side signed-URL pattern.

## Symptom

Two failure modes, both silent in different ways:

**(A) Data leak.** Users upload "private" files — avatars, invoices, medical docs — to a Supabase Storage bucket. The upload works. Then a second user (or a logged-out browser) guesses or iterates the object path and reads another user's file. No error, no log line, no audit trail. The bucket is effectively public. This is the "it works on localhost" trap in reverse: local dev often uses the `service_role` key (which bypasses RLS), so the leak only surfaces when you test against a real `authenticated` / `anon` client in a deployed environment.

**(B) Broken uploads.** After tightening policies, legitimate uploads start failing. The client gets a 403; the Postgres log shows `new row violates row-level security policy` on `storage.objects` — for the owner. Re-uploads (overwrite) fail; first uploads fail; or `list()` returns empty for the owner. The fix you applied was too narrow or targeted the wrong operation.

## Impact

A private-bucket leak is the highest-severity incident this repo covers: it is direct exfiltration of user data (PII, invoices, medical records) with no error and no detectable signal in your error pipeline. Because the failure is permissive (extra rows visible) rather than restrictive (rows hidden), your observability — tuned for errors and empty results — stays quiet. Trust erosion is immediate and legal exposure is real (GDPR/HIPAA-style obligations). Rollbacks do nothing: the bug is in the bucket definition and the policy set, not in code.

Mode (B) is lower-severity but more visible: uploads fail loudly, users can't onboard, and the team wastes hours grepping the app for the cause when the cause is a missing `update` policy on `storage.objects`.

## Root cause — five causes, each verifiable against Supabase docs

### Cause 1 — Bucket vs object policies (two layers)

Supabase Storage has **two** RLS-protected tables, not one: `storage.buckets` (who can manage the bucket itself) and `storage.objects` (who can read/write an object). Most leaks come from conflating them — a developer reads "RLS is on" and assumes object reads are scoped, but the bucket was created `public` (see Cause 2) or the `storage.objects` `select` policy doesn't scope by `owner_id` or `auth.uid()`. Per the access-control docs: "by default Storage does not allow any uploads to buckets without RLS policies" — but reads of public buckets bypass RLS entirely, and reads of private buckets require a `select` policy on `storage.objects` that actually matches the calling role.

### Cause 2 — Public vs private buckets

A **public bucket** serves any object to anyone via the conventional URL `https://[project_id].supabase.co/storage/v1/object/public/[bucket]/[asset-name]` — RLS is bypassed for reads and serving, even though upload/delete/move/copy still enforce policies. Fine for avatars, fatal for invoices. A **private bucket** (the default) requires either a JWT-authenticated download request or a signed URL. The single most common leak is a bucket created with `public = true` for content that should be private — there is no object-level policy that can undo that; the read path skips RLS.

### Cause 3 — PUT (upsert / `x-upsert: true`) vs POST (create)

Upload semantics map to different SQL permissions:

- **POST (create, new object):** requires `INSERT` on `storage.objects`.
- **PUT / upsert (`x-upsert: true`, overwrite existing):** per the access-control docs, "to allow overwriting files using the `upsert` functionality you will need to additionally grant `SELECT` and `UPDATE` permissions." So upsert = `INSERT` + `SELECT` + `UPDATE`.

A policy that allows only `for insert` makes the first upload succeed and every re-upload of the same path 403 — the `update` clause is missing. This is the classic "owner can't re-upload" failure mode.

### Cause 4 — `owner_id` column + `storage.foldername(name)` naming

The canonical ownership pattern uses the `owner_id` column (set from the JWT `sub` claim when the object is created through the API) compared against `auth.uid()`, **or** a path-based pattern using `(storage.foldername(name))[1]` as the owner id. The legacy `owner` column (uuid) is deprecated; use `owner_id` (text). Two ways this goes wrong:

- **Wrong predicate:** policy uses `auth.uid() = owner` (the deprecated uuid column) instead of `owner_id = (select auth.uid()::text)`. The owner's own reads return empty / fail.
- **Wrong path convention:** the app writes to `avatars/123.png` but the policy expects `(storage.foldername(name))[1] = auth.uid()` — i.e., the leading folder must be the user's id (`<uid>/avatar.png`). Mismatch → owner can't read their own file, or the predicate is trivially true and everyone reads.

Note: objects created with the `service_key` or via the Dashboard have **no `owner_id` set** — they are effectively owned by anyone. A policy keyed on `owner_id` will deny everyone, including the legitimate admin.

### Cause 5 — Signed URLs vs public URLs

Signed URLs are the correct pattern for private-bucket reads from a client. They are time-limited, signed with a dedicated internal key separate from the project's Auth JWT signing key, and remain valid until expiry regardless of Auth key changes. Two gotchas:

- **Generating a signed URL is itself a `storage.objects` operation** — the server-side call must be made with a role that has `select` on `storage.objects` for that path (typically `service_role`, which bypasses RLS, or an authenticated user with their own `select` policy). If the server uses the `anon` key with no matching `select` policy, `createSignedUrl` returns an error or a URL that won't resolve.
- **Signed URLs are bearer tokens, not user-scoped.** Once handed to a client, anyone the client shares the URL with can read the object until expiry. They are the right tool for short-lived access; they are not a substitute for path-scoped RLS when the threat model includes a malicious authenticated user sharing links. Keep expiry short (minutes-to-hours, not days).

## Decision matrix

| Situation | Bucket | Object policy | Read mechanism |
| --- | --- | --- | --- |
| Public avatars / marketing images | `public = true` | `insert/update/delete` scoped by owner; reads bypass RLS | `getPublicUrl(path)` — static, cacheable |
| Per-user private docs (invoices, medical) | `public = false` | `select/insert/update/delete` scoped by `owner_id = auth.uid()` or `(storage.foldername(name))[1] = auth.uid()` | `createSignedUrl(path, 60)` server-side, short TTL |
| Admin-managed assets (service_key writes) | `public = false` | `select` for `authenticated` via a custom role; `owner_id` is null so don't key on it | `createSignedUrl` from an Edge Function using `service_role` |
| Re-upload / overwrite (upsert) | either | must include `for update` **and** `for select` in addition to `for insert` | upload via `x-upsert: true` header |
| Sharing a single private file with a third party | `public = false` | owner-scoped policies unchanged | `createSignedUrl(path, 300)` — one-off, short TTL, bearer token |

## Detection (run these now)

### Query 1 — Bucket public-ness (the smoking gun for mode A)

```sql
select id, name, public from storage.buckets order by name;
```

- **Expected (healthy for private content):** `public = false` for every bucket holding private content (invoices, medical, docs).
- **Actual (incident, mode A):** the bucket holding private content has `public = true`. Any object in it is readable by anyone with the URL — no object policy can fix this; you must set `public = false` (or move the content).

### Query 2 — Effective object policies on `storage.objects`

```sql
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
where schemaname = 'storage'
  and tablename = 'objects'
order by policyname;
```

- **Expected (healthy private bucket):** four policies — `cmd in ('select','insert','update','delete')` — each `to authenticated`, each with a `qual`/`with_check` that scopes by `bucket_id` **and** (`owner_id = (select auth.uid()::text)` **or** `(storage.foldername(name))[1] = (select auth.uid()::text)`).
- **Actual (incident, mode A):** a `select` policy with `using (true)` or no `bucket_id`/owner predicate — anyone authenticated can read any object. Or no `select` policy at all but the bucket is `public` (so reads bypass RLS).
- **Actual (incident, mode B):** `insert` policy present, but `update` policy missing (upsert 403), or `select` policy missing (signed-URL generation / `list()` fails for the owner).

### Query 3 — Confirm the `owner_id` column exists and how it's used

```sql
select
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'storage'
  and table_name = 'objects'
  and column_name in ('owner_id', 'owner', 'bucket_id', 'name');
```

- **Expected:** `owner_id` (text) present. If only the legacy `owner` (uuid) exists, you're on an old schema and policies keyed on `owner` will silently fail against `auth.uid()::text`.
- **Actual (incident):** `owner_id` present but policies reference the deprecated `owner` column — owner's own reads/uploads 403.

### Query 4 — Repro: upload as A, read as B (the actual leak test)

The decisive test. Use two real user tokens, not `service_role` (which bypasses RLS and tells you nothing).

```ts
// 1. As user A (authenticated), upload to a private bucket:
const supabaseA = createClient(URL, A_ACCESS_TOKEN)
await supabaseA.storage.from('invoices').upload(`${A_UID}/invoice.pdf`, file)

// 2. As user B (different authenticated user), attempt to read A's file:
const supabaseB = createClient(URL, B_ACCESS_TOKEN)
const { data, error } = await supabaseB.storage
  .from('invoices')
  .download(`${A_UID}/invoice.pdf`)
// LEAK if data is not null and error is null — B read A's file.

// 3. Logged out (anon key only), attempt the public URL:
const anonUrl = `${URL}/storage/v1/object/public/invoices/${A_UID}/invoice.pdf`
const res = await fetch(anonUrl)
// LEAK if res.status === 200 and the bucket is supposed to be private.
```

- **Expected (healthy):** step 2 returns an error / null; step 3 returns 400/404 (bucket not public).
- **Actual (incident, mode A):** step 2 or 3 returns the file content — confirmed leak.

## Fix

### Step 1 — Make the bucket private

```sql
-- If the bucket currently has public = true and holds private content, fix it:
update storage.buckets set public = false where id = 'invoices';

-- Verify:
select id, name, public from storage.buckets where id = 'invoices';
```

### Step 2 — Apply the canonical per-owner object policy set

Copy-ready. Scopes all four operations on `storage.objects` to the owner, using `(storage.foldername(name))[1]` as the owner id (the path convention is `<uid>/<filename>`). Replace `private_bucket` with your bucket id.

```sql
-- Private bucket: per-owner policies on storage.objects.
-- Convention: objects are stored as <auth.uid()>/<filename>, so the leading
-- folder segment is the owner id. We scope every operation by bucket_id AND
-- by that leading folder matching the authenticated user's uid.

-- Allow each authenticated user to read their own objects.
create policy "objects.select own"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'private_bucket'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

-- Allow each authenticated user to upload (POST / create new) into their folder.
create policy "objects.insert own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'private_bucket'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

-- Allow each authenticated user to overwrite their own objects (PUT / upsert).
-- Without this, re-uploads (x-upsert: true) fail with RLS 403.
create policy "objects.update own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'private_bucket'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  )
  with check (
    bucket_id = 'private_bucket'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

-- Allow each authenticated user to delete their own objects.
create policy "objects.delete own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'private_bucket'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );
```

**Owner-id alternative** (use `owner_id` instead of the path convention — appropriate when the app writes arbitrary paths and you trust the JWT-derived `owner_id`):

```sql
create policy "objects.select own by owner_id"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'private_bucket'
    and owner_id = (select auth.uid()::text)
  );
-- Apply the same owner_id predicate to insert (with check), update, and delete.
```

### Step 3 — Generate signed URLs server-side for reads

The signed URL must be generated with a role that can read the object. The clean pattern in Next.js App Router is a Route Handler (or Server Action) using the `service_role` key (server-only, never shipped to the browser):

```ts
// app/api/storage/signed-url/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

export async function GET(req: NextRequest) {
  const path = req.nextUrl.searchParams.get('path')
  if (!path) return NextResponse.json({ error: 'missing path' }, { status: 400 })

  // Server-only: service_role bypasses RLS. NEVER expose this key to the client.
  const admin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  )

  // Short TTL — signed URLs are bearer tokens; keep the window small.
  const { data, error } = await admin.storage
    .from('private_bucket')
    .createSignedUrl(path, 60) // 60 seconds

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ signedUrl: data.signedUrl })
}
```

For per-user access without `service_role`, generate the signed URL with the user's own access token (an authenticated client whose `select` policy matches the path) — same short-TTL guidance applies.

### Step 4 — Upload with the upsert header correctly

```ts
// First upload (POST semantics): insert policy is enough.
await supabase.storage.from('private_bucket')
  .upload(`${user.id}/invoice.pdf`, file)

// Re-upload / overwrite (PUT semantics): upsert: true triggers INSERT + SELECT + UPDATE.
// All three policies from Step 2 must be in place or this 403s.
await supabase.storage.from('private_bucket')
  .upload(`${user.id}/invoice.pdf`, file, { upsert: true })
```

### The critical step: test as the real authenticated user

Never validate storage RLS with the `service_role` key — it bypasses policies, so a passing test tells you nothing. Re-run the repro in Query 4 above (upload as A, read as B and as anon) with real user tokens. Only mark the incident resolved when:

- Step 2 (B reads A's file) returns an error / null.
- Step 3 (anon public URL) returns non-200 for the private bucket.
- A can still upload, re-upload (upsert), list, and delete their own files.

## Prevention

### CI gate — no `public` bucket holds private-content paths

Append to [rls-audit.sql](../sql/rls-audit.sql). Empty result = pass; any row = fail the pipeline.

```sql
-- storage-public-bucket-gate.sql
-- Fails if any bucket flagged public holds a path convention that looks private
-- (invoices, medical, docs, kyc, etc.). Tune the path_prefix list for your app.
with private_path_buckets as (
  select b.id, b.name
  from storage.buckets b
  where b.public = true
    and exists (
      select 1
      from storage.objects o
      where o.bucket_id = b.id
        and (
          o.name ~* '(invoices|medical|docs|kyc|kyc-documents)/'
          or (storage.foldername(o.name))[1] ~* '^(invoices|medical|kyc)$'
        )
    )
)
select id, name as public_bucket_with_private_content
from private_path_buckets
order by name;
```

### CI gate — every private bucket has all four object policies

```sql
-- storage-object-policy-gate.sql
-- Fails if a non-public bucket lacks any of select/insert/update/delete on storage.objects.
with private_buckets as (
  select id from storage.buckets where public = false
),
required_cmds as (
  select * from (values ('select'), ('insert'), ('update'), ('delete')) as c(cmd)
)
select pb.id as private_bucket_missing_policy,
       rc.cmd as missing_cmd
from private_buckets pb
cross join required_cmds rc
where not exists (
  select 1
  from pg_policies p
  where p.schemaname = 'storage'
    and p.tablename = 'objects'
    and p.cmd = rc.cmd
    and p.qual like '%' || pb.id || '%'
)
order by pb.id, rc.cmd;
```

Wire either gate as a pgTAP test in CI: `select ok(count(*) = 0, 'no public bucket holds private content') from ( …query… ) g;`

### Cross-user e2e test — upload as A, assert B cannot read

A Playwright (or pgTAP) step that runs on every preview deploy:

```sql
-- pgTAP sketch: authenticated user B cannot SELECT user A's object.
select tests.run(
  'cross-user storage isolation',
  select is(
    'select count(*) from storage.objects where bucket_id = ''private_bucket'' and (storage.foldername(name))[1] = ''' || A_UID || '''',
    0::bigint,
    'user B sees zero of user A''s objects'
  )
);
```

Or in Playwright: sign in as A, upload; sign out, sign in as B, attempt `download(A's path)`; assert error. Then sign out and fetch the public URL; assert non-200.

### Code-review checklist line

Add to your PR template: "Storage change? Bucket `public` flag verified for the content class? All four object policies (`select/insert/update/delete`) present and scoped by `owner_id` or `(storage.foldername(name))[1]`? Cross-user test (A uploads, B denied) run against a real authenticated token, not `service_role`?"

## References

- Supabase Storage Access Control — https://supabase.com/docs/guides/storage/security/access-control
- Supabase Storage Helper Functions (`storage.foldername`, `storage.extension`, `storage.allow_only_operation`) — https://supabase.com/docs/guides/storage/schema/helper-functions
- Supabase Storage Ownership (`owner_id` vs deprecated `owner`) — https://supabase.com/docs/guides/storage/security/ownership
- Supabase Storage Buckets Fundamentals (public vs private) — https://supabase.com/docs/guides/storage/buckets/fundamentals
- Supabase Storage Serving / Downloads (`getPublicUrl` vs `createSignedUrl`) — https://supabase.com/docs/guides/storage/serving/downloads
- Supabase JavaScript: `getPublicUrl` reference — https://supabase.com/docs/reference/javascript/file-buckets-getpublicurl
- Supabase Storage Schema Design (`storage.objects`, `storage.buckets`, `owner_id`, `path_tokens`) — https://supabase.com/docs/guides/storage/schema/design
- [RLS Audit SQL](../sql/rls-audit.sql)
- [RLS empty-array postmortem](../playbooks/rls-empty-array-postmortem.md)