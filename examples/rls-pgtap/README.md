# RLS + pgTAP — Broken vs Fixed, with Automated Verification

A self-contained, runnable example showing five real production Row-Level-Security (RLS) incidents from Next.js + Supabase apps, each demonstrated as a **BROKEN** policy and a **FIXED** policy, verified automatically with [pgTAP](https://pgtap.org/).

Runs on **plain PostgreSQL + pgTAP** — no Supabase, no Docker. Works in CI with a `postgres` service container and locally with `pg_prove`.

---

## What this demonstrates

| Incident | One-line |
|----------|----------|
| **INC-002** | RLS enabled, no `SELECT` policy → authenticated users see an empty array (0 rows) even though rows exist. |
| **INC-003** | A `SELECT` policy that `EXISTS(...)` against the same table → infinite recursion error at query time. |
| **INC-015** | RLS predicate on an unindexed column → `Seq Scan`; add an index → `Index Scan`. |
| **INC-018** | `service_role` (`BYPASSRLS`) sees all rows; `authenticated` is scoped. An ORM connected as `service_role` leaks every tenant. |
| **INC-021** | Storage `objects` with an unscoped/public policy (`USING (true)`) leaks every owner's objects; owner-scoped policy protects. |

---

## Prerequisites

- PostgreSQL 14+ (tested shape; 15/16/17 all fine).
- The `pgtap` extension: `CREATE EXTENSION pgtap;` in the target database (the run scripts do this for you via `00_setup.sql`).
- `pg_prove` (ships with pgTAP, or install separately).

On Debian/Ubuntu: `sudo apt install postgresql-client libdbd-pg-perl postgresql-<ver>-pgtap` and `cpan TAP::Parser::SourceHandler::pgTAP` (or install `pg_prove` from the pgTAP release tarball). On macOS with Homebrew: `brew install postgresql@16 libpq` and `cpan TAP::Parser::SourceHandler::pgTAP`.

---

## Quick start

```bash
# from this directory
createdb rls_pgtap_example
./run.sh         # bash: applies FIXED -> tests pass -> BROKEN demo -> re-fixed
# or on Windows PowerShell:
#   .\run.ps1
```

The run script:
1. Creates the database if missing.
2. Applies `sql/00_setup.sql`, `sql/01_schema.sql`, `sql/02_rls_fixed.sql`.
3. Runs `pg_prove tests/*.test.sql` — **all pass**.
4. Applies `sql/03_rls_broken.sql` and re-runs the suite to **reproduce the incidents** (tests 001 and 005 fail; 002 errors on recursion).
5. Re-applies `02_rls_fixed.sql` and confirms all pass again.

Override connection details with env vars: `DB=…`, `PGUSER=…`, `PGHOST=…`, `PGPORT=…`.

---

## Manual run

```bash
createdb rls_pgtap_example
psql -d rls_pgtap_example -f sql/00_setup.sql
psql -d rls_pgtap_example -f sql/01_schema.sql
psql -d rls_pgtap_example -f sql/02_rls_fixed.sql
pg_prove -d rls_pgtap_example tests/
```

To reproduce the broken behavior:

```bash
psql -d rls_pgtap_example -f sql/03_rls_broken.sql
pg_prove -d rls_pgtap_example tests/   # 001/005 fail, 002 errors on recursion
```

---

## What each test proves

- `001_empty_array.test.sql` — User A inserts 2 posts, user B inserts 1. Under the FIXED `posts_sel` policy, authenticated A sees their 2; `anon` sees 0. (Under the broken setup, `authenticated` also sees 0 — the INC-002 trap; `run.sh` demonstrates this.)
- `002_recursion.test.sql` — The FIXED direct predicate (`user_id = auth.uid()`) returns A's rows without recursion. (The broken self-referential `EXISTS(... posts ...)` policy raises an infinite-recursion error; `run.sh` demonstrates this.)
- `003_latency_index.test.sql` — 500 rows for A + 10 for B; `EXPLAIN` of `SELECT … WHERE user_id = A` under the FIXED policy + `posts_user_idx` uses an `Index Scan`, not a `Seq Scan`.
- `004_orm_role_bypass.test.sql` — `service_role` (`BYPASSRLS`) sees all 5 rows across both tenants; `authenticated` A sees only their 3 and cannot read B's rows by id. The lesson: an ORM connected as `service_role` bypasses every policy.
- `005_storage.test.sql` — A owns 2 `example_objects`, B owns 1. Under the FIXED owner-scoped `objects_sel` policy, A sees only their 2 and cannot read B's object. (The broken `USING (true)` policy leaks all 3; `run.sh` demonstrates this.)

---

## CI

The repo's CI (or yours) can do:

```yaml
services:
  postgres:
    image: postgres:17
    env:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: rls_pgtap_example
    ports: [5432:5432]

steps:
  - run: psql -h localhost -U postgres -d rls_pgtap_example -c "CREATE EXTENSION pgtap;"
  - run: psql -h localhost -U postgres -d rls_pgtap_example -f examples/rls-pgtap/sql/00_setup.sql
  - run: psql -h localhost -U postgres -d rls_pgtap_example -f examples/rls-pgtap/sql/01_schema.sql
  - run: psql -h localhost -U postgres -d rls_pgtap_example -f examples/rls-pgtap/sql/02_rls_fixed.sql
  - run: pg_prove -h localhost -U postgres -d rls_pgtap_example examples/rls-pgtap/tests/
```

All five tests should pass against the FIXED schema.

---

## The `auth.uid()` mock

Plain PostgreSQL has no Supabase `auth.uid()`. `sql/00_setup.sql` provides a faithful mock that reads the same GUC Supabase uses (`request.jwt.claims`):

```sql
CREATE OR REPLACE FUNCTION auth.uid() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT (NULLIF(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid
$$;
```

Tests act as a specific user with:

```sql
SET LOCAL ROLE authenticated;     -- local to the transaction
SELECT set_test_user('<uuid>');   -- sets request.jwt.claims
```

Because pgTAP wraps each test file in a transaction, the `set_config(..., true)` scope is exactly the test.

---

## Real Supabase note

In real Supabase:

- `auth.uid()` reads the JWT from `request.jwt.claims` automatically — the mock above mirrors that exactly.
- The storage table is `storage.objects`, and the real owner rule is `(storage.foldername(name))[1] = auth.uid()`. We use a plain `owner_id` column here for clarity; the policy shape is identical.
- `service_role` carries `BYPASSRLS` server-side; never expose it to the browser. Use it only for trusted server-side work (webhooks, migrations) and prefer `authenticated` for any user-facing query.

See the linked playbooks for the full postmortems.

---

## File layout

```
examples/rls-pgtap/
  README.md
  sql/
    00_setup.sql          # roles, auth.uid() mock, set_test_user helper
    01_schema.sql         # tenants, profiles, posts, example_objects (RLS enabled)
    02_rls_fixed.sql      # corrected policies + posts_user_idx
    03_rls_broken.sql     # broken policies (no select; self-recursive; public objects)
  tests/
    001_empty_array.test.sql
    002_recursion.test.sql
    003_latency_index.test.sql
    004_orm_role_bypass.test.sql
    005_storage.test.sql
  run.sh                  # bash runner (FIXED -> BROKEN demo -> re-FIXED)
  run.ps1                 # PowerShell runner (same phases)
  .gitignore
```

---

## References

- [INC-002 — RLS empty-array postmortem](../../reference/playbooks/rls-empty-array-postmortem.md)
- [INC-018 — ORM bypassing RLS postmortem](../../reference/playbooks/orm-bypassing-rls-postmortem.md)
- [INC-021 — Storage RLS upload postmortem](../../reference/playbooks/storage-rls-upload-postmortem.md)
- [Incident index](../../reference/incident-index/README.md)
- [pgTAP](https://pgtap.org/) — the test framework used here (no other external links referenced).