# Runnable Examples

Minimal, production-oriented, **independently runnable** examples that reproduce real Next.js + Supabase + Stripe incidents. Each example ships a **broken** implementation and the **corrected** implementation side by side, plus **automated verification** (pgTAP or Vitest) that demonstrates the bug and proves the fix.

These examples turn the [Incident Index](../reference/incident-index/README.md) into something you can actually *run*.

## Why

The repo's [reference assets](../reference/playbooks/) explain *what* breaks and *why*. These examples let you *watch it break*, then *watch the fix pass* — in seconds, on your machine or in CI. Every example is pinned to one or more incidents so the lesson is traceable.

## Examples

| Example | Demonstrates (incidents) | Runner | Prerequisites | Verification |
| --- | --- | --- | --- | --- |
| [rls-pgtap](rls-pgtap/README.md) | INC-002 empty array, INC-003 recursion, INC-015 latency/index, INC-018 ORM/role bypass, INC-021 storage leak | `pg_prove` on plain PostgreSQL | PostgreSQL 14+, `pgtap` extension, `pg_prove` | 5 pgTAP files |
| [stripe-webhook-idempotency](stripe-webhook-idempotency/README.md) | INC-006 signature, INC-007 duplicate rows, INC-012 timeout/lease, INC-016 200-but-wrong | Vitest (no external services) | Node 20+ | 7 tests |
| [nextjs15-cache-and-params](nextjs15-cache-and-params/README.md) | INC-008 revalidate stale, INC-011 stale UI after Server Action, INC-020 async params | Vitest (no external services) | Node 20+ | 8 tests |

The three examples cover **13 of the 21 incidents** — chosen for maximum reuse.

## Convention

- `broken/` or `*.broken.*` = the bug. `fixed/` or `*.fixed.*` = the correction. Both ship in-repo so the **diff is the lesson**.
- Each example is **self-contained** — no shared runtime, no monorepo, no imposed package manager. `cd` into the folder, follow its README.
- Each example README links back to the incident playbook(s) it reproduces under `../reference/playbooks/`.

## Running an example

Each example's README is the source of truth. The short version:

```bash
# rls-pgtap (needs PostgreSQL + pgTAP)
cd examples/rls-pgtap && ./run.sh          # fixed passes, broken reproduces, fixed again passes
# or: createdb rls_pgtap_example && psql -d rls_pgtap_example -f sql/00_setup.sql -f sql/01_schema.sql -f sql/02_rls_fixed.sql && pg_prove -d rls_pgtap_example tests/

# stripe-webhook-idempotency (needs Node)
cd examples/stripe-webhook-idempotency && npm ci && npm test

# nextjs15-cache-and-params (needs Node)
cd examples/nextjs15-cache-and-params && npm ci && npm test
```

## CI

`.github/workflows/examples-ci.yml` runs the **dependency-light** verifications on PRs touching `examples/**`:

- **vitest job** — `npm ci && npm test` in the two Vitest examples. Zero external services.
- **pgtap job** — a `postgres:17` container with the `pgtap` extension installed, applies the FIXED schema, runs `pg_prove`. Proves the fixed suite is green.

The **broken-vs-fixed demo** (`run.sh`) and the **heavier** runners (Playwright, k6) are **local-only** — documented in each example, not wired into CI — to keep CI fast and green. (See the Tier 2 roadmap below.)

This `examples-ci` workflow is **not** a required branch-protection check; it surfaces regressions without blocking merges.

## Tier 1 / Tier 2

This is **Tier 1** (3 examples). Planned **Tier 2** follow-ups (local-only unless noted):

- `realtime-tab-suspension` — Playwright e2e simulating background-tab suspension + resync-on-reconnect (INC-019).
- `connection-pooling` — k6 load scenario + Supavisor/`pg_stat_activity` introspection scripts (INC-017).

## Adding an example

1. Create `examples/<name>/` with its own `README.md`, a broken and a fixed implementation, and a runnable test suite (pgTAP or Vitest).
2. Tie it to one or more incidents: link the incident playbook in your README, and append an example link to the matching row(s) in [../reference/incident-index/README.md](../reference/incident-index/README.md).
3. Prefer artifacts multiple incidents can reference (reuse > volume).
4. If the verification is dependency-light, add it to `.github/workflows/examples-ci.yml`.