# AGENTS.md — Next.js + Supabase Production Rules

Drop-in guardrails for AI coding agents (Cursor, GitHub Copilot, Claude Code, Windsurf, and any tool that reads `AGENTS.md`) working on a **Next.js (App Router) + Supabase + Stripe** project.

AI tools confidently generate code that works on localhost and silently breaks in production — empty RLS results, lost SSR sessions, redirect loops, duplicate Stripe charges, stale UI after mutations. These rules encode the fixes for the most common failures, mapped to the [Production Incident Index](reference/incident-index/README.md).

**How to use:** copy this file (and `.cursor/rules/`) into your own repo root. Most agents read `AGENTS.md` automatically; Cursor reads `.cursor/rules/*.mdc`.

---

## Auth and Sessions

- **Always `await cookies()`** in the App Router. Reading cookies synchronously throws the `cookies() should be awaited` warning and breaks server rendering. (INC-001)
- **Never protect `/auth/callback` or the login route** in middleware. If the matcher covers them, OAuth loops back to login forever. Exclude callback and login paths explicitly. (INC-004)
- **Use the `@supabase/ssr` client on the server**, not the browser client. The SSR client must read and write cookies, or the session vanishes on refresh. Verify cookie `domain` matches across prod and preview deployments. (INC-005)
- **Refresh the session in middleware** by passing cookies through both request and response. A missing refresh path is the #1 cause of "logged out after reload."

## Middleware

- **Scope the matcher narrowly.** Never let it match `_next/static`, `_next/image`, favicons, or other public assets — it breaks static delivery and adds latency. Exclude them with a negative-lookahead matcher. (INC-014)
- Middleware runs on the Edge runtime. Do not use Node-only APIs there.

## Row Level Security (RLS)

- **Enabling RLS without a `SELECT` policy returns an empty array, not an error.** If queries silently return `[]` for rows that exist, the policy is missing — not the data. Add scoped policies per role and test with both anon and authenticated clients. (INC-002)
- **Never write a policy that queries its own table through nested `EXISTS`** — it causes infinite recursion. Move the check into a `SECURITY DEFINER` helper function or a separate table/view. (INC-003)
- **Index every column used in a policy predicate** (`user_id`, `tenant_id`, `org_id`). Unindexed predicates turn RLS into a full scan and make the API unusably slow. Validate with `EXPLAIN ANALYZE`. (INC-015)
- Wrap `auth.uid()` in a `SELECT` (`(SELECT auth.uid())`) inside policies so Postgres caches it per-statement instead of per-row.

## Server Actions and Caching

- **`revalidatePath` / `revalidateTag` must target the exact path or tag the cached fetch used.** A mismatch means the mutation commits but the UI shows stale data. Verify the revalidation target with server logs. (INC-008, INC-011)
- **User-scoped data must render dynamically.** Mixing static and dynamic boundaries serves cached, cross-user state. Force dynamic rendering for anything behind auth.
- Revalidate **after** the database write resolves, never optimistically before the commit.

## Stripe and Billing

- **Verify the webhook signature against the raw request body.** Any body parsing or transformation before verification fails the signature check. Use the environment-scoped endpoint secret (test vs live). (INC-006)
- **Make every webhook handler idempotent.** Stripe retries events; without a persisted `event.id` dedup store you get duplicate subscription rows and double-grants. Reject seen event IDs before mutating state. (INC-007)
- **Keep webhook handlers short.** Offload long work to a queue; a slow Edge handler times out and Stripe retries it. (INC-012)

## Migrations and Deployment

- **Staging success does not guarantee prod success.** Account for data shape, extension availability, and lock contention. Use preflight checks and rehearse the rollback. (INC-009)
- **Budget lock time on rollback.** Set `lock_timeout`, use phased/expand-contract changes, and never run an unbounded rollback against live writes. (INC-010)

## AI and pgvector

- **Pin embedding dimensions and a reindex strategy.** Mismatched dimensions or missing maintenance cause latency spikes after index changes. Benchmark with `EXPLAIN` before deploying index changes. (INC-013)

---

## Verification Checklist (run before declaring a feature done)

- [ ] Queried data as both anon and authenticated — no silent empty arrays.
- [ ] Session survives a hard refresh in a preview deployment.
- [ ] OAuth callback and login routes are excluded from the middleware matcher.
- [ ] Static assets load (no middleware on `_next/*`).
- [ ] Mutation revalidates the exact path/tag the UI reads.
- [ ] Stripe webhook verifies raw body and dedupes by event ID.
- [ ] Policy predicate columns are indexed; checked with `EXPLAIN ANALYZE`.

When unsure, consult the [Production Incident Index](reference/incident-index/README.md) and the [Debugging Playbook](content/debugging-playbook/README.md) in this repository.
