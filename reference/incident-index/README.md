# Incident Index: Next.js + Supabase + Stripe Production Problems and Fixes

Last verified: 2026-05-24

> This is the numbered catalog mapping each incident to a reusable asset in this repo. For a broader symptom-organized debugging reference with links to the official docs, see the [Symptom Reference](../../content/incidents/README.md).

| Problem | Stack (Next.js / Supabase / Stripe) | Root Cause | Fix | Reference Asset Link |
| --- | --- | --- | --- | --- |
| INC-001: `cookies() should be awaited` runtime warning in App Router | Next.js | Reading cookies in contexts that became async in newer runtime behavior. | Use `await cookies()` where required and isolate cookie access in server boundaries. | [Server Actions debugging matrix](../playbooks/server-actions-debugging-matrix.md) |
| INC-002: Supabase returns empty array for existing rows | Supabase | RLS enabled but no matching `select` policy for authenticated role. | Add scoped `select` policies and test with anon/authenticated clients. | [RLS audit SQL](../sql/rls-audit.sql) |
| INC-003: Infinite recursion detected in policy | Supabase | Policy references the same table recursively through nested `exists` logic. | Split policy concerns, move recursion checks to helper tables/views, and index predicates. | [RLS audit SQL](../sql/rls-audit.sql) |
| INC-004: OAuth callback loops to login in App Router | Next.js + Supabase | Middleware matcher protects `/auth/callback` or login path. | Exclude callback/login routes from protected matcher and verify cookie write path. | [Server Actions debugging matrix](../playbooks/server-actions-debugging-matrix.md) |
| INC-005: Session disappears after refresh in SSR | Next.js + Supabase | Server-side cookie refresh path not wired or wrong domain settings. | Validate SSR client cookie flow and domain attributes in prod/preview. | [Server Actions debugging matrix](../playbooks/server-actions-debugging-matrix.md) |
| INC-006: Webhook signature verification failed | Stripe | Wrong endpoint secret, transformed body, or environment mismatch. | Verify raw body handling and use environment-scoped webhook secret. | [Stripe webhook idempotency template](../templates/stripe-webhook-idempotency-template.sql) |
| INC-007: Duplicate subscription rows from retries | Stripe + Supabase | No idempotency store for webhook event IDs. | Persist event IDs and reject duplicates before state mutation. | [Stripe webhook idempotency template](../templates/stripe-webhook-idempotency-template.sql) |
| INC-008: `revalidatePath` runs but stale data persists | Next.js + Supabase | Mutation path and revalidated path/tag do not match data boundary. | Revalidate exact route/tag tied to cached fetch key and verify with server logs. | [Server Actions debugging matrix](../playbooks/server-actions-debugging-matrix.md) |
| INC-009: Migration succeeds in staging and fails in prod | Supabase + PostgreSQL | Hidden assumptions on data shape, extension availability, or locks. | Use preflight checks, lock-aware migrations, and rollback script rehearsals. | [Zero-downtime rollout checklist](../checklists/zero-downtime-rollout-checklist.md) |
| INC-010: Rollback blocks writes for too long | Supabase + PostgreSQL | Rollback plan missing lock budget and phased fallback strategy. | Define lock timeout budgets and run tested rollback playbook. | [Migration rollback playbook](../playbooks/migration-rollback-playbook.md) |
| INC-011: Server Actions write succeeds but UI reads old state | Next.js | Mixed static and dynamic rendering boundaries with stale cache tags. | Enforce dynamic boundaries for user-scoped data and revalidate targeted tags. | [Server Actions debugging matrix](../playbooks/server-actions-debugging-matrix.md) |
| INC-012: Edge Function webhook processing times out | Supabase + Stripe | Long-running logic and no queue handoff for retries. | Use queue handoff pattern and keep edge handlers idempotent and short. | [Stripe webhook idempotency template](../templates/stripe-webhook-idempotency-template.sql) |
| INC-013: pgvector query latency spikes after index changes | Supabase + PostgreSQL | Missing maintenance/reindex strategy and inconsistent embedding dimensions. | Validate dimensions, inspect plans, and benchmark before deploy. | [pgvector benchmark template](../templates/pgvector-benchmark-template.md) |
| INC-014: Middleware auth breaks static assets | Next.js | Matcher scope accidentally includes `_next/static` or image paths. | Narrow matcher and explicitly exclude static/runtime paths. | [Server Actions debugging matrix](../playbooks/server-actions-debugging-matrix.md) |
| INC-015: RLS policy slows API to unusable latency | Supabase + PostgreSQL | Policy predicates missing supporting indexes on tenant/user columns. | Add composite indexes and validate with `EXPLAIN ANALYZE`. | [RLS audit SQL](../sql/rls-audit.sql) |
| INC-016: Webhook returns 200 OK but business state is wrong | Stripe + Supabase | Event dedup is in place, but side effects are not independently idempotent, or the event is marked processed before the side effects commit. | Track processing state, not just "seen"; make each side effect idempotent with its own unique key; only return 200 after side effects commit; backfill missed events from the Stripe API. | [Stripe webhook idempotency template](../templates/stripe-webhook-idempotency-template.sql), [Stripe webhook test plan](../playbooks/stripe-webhook-test-plan.md) |

## Incident Anchor Map

Use these anchors for guide-level internal links.

- [INC-001](#inc-001-cookies-should-be-awaited-runtime-warning-in-app-router)
- [INC-002](#inc-002-supabase-returns-empty-array-for-existing-rows)
- [INC-003](#inc-003-infinite-recursion-detected-in-policy)
- [INC-004](#inc-004-oauth-callback-loops-to-login-in-app-router)
- [INC-005](#inc-005-session-disappears-after-refresh-in-ssr)
- [INC-006](#inc-006-webhook-signature-verification-failed)
- [INC-007](#inc-007-duplicate-subscription-rows-from-retries)
- [INC-008](#inc-008-revalidatepath-runs-but-stale-data-persists)
- [INC-009](#inc-009-migration-succeeds-in-staging-and-fails-in-prod)
- [INC-010](#inc-010-rollback-blocks-writes-for-too-long)
- [INC-011](#inc-011-server-actions-write-succeeds-but-ui-reads-old-state)
- [INC-012](#inc-012-edge-function-webhook-processing-times-out)
- [INC-013](#inc-013-pgvector-query-latency-spikes-after-index-changes)
- [INC-014](#inc-014-middleware-auth-breaks-static-assets)
- [INC-015](#inc-015-rls-policy-slows-api-to-unusable-latency)
- [INC-016](#inc-016-webhook-returns-200-ok-but-business-state-is-wrong)
