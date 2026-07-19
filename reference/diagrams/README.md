# Production Architecture Diagrams for Next.js + Supabase Systems

Last verified: 2026-07-19

Use these diagrams for onboarding, incident retrospectives, and architecture reviews. Each diagram file is self-contained Mermaid that GitHub renders inline.

## Built

- [RLS request flow](rls-request-flow.md) — Problem -> fix -> production guide for RLS policy evaluation (browser -> middleware -> SSR auth -> RLS -> database).
- [Stripe webhook retry & idempotency state machine](stripe-webhook-state-machine.md) — The `received -> processing -> processed | failed` state machine from the [idempotency SQL template](../templates/stripe-webhook-idempotency-template.sql), tied to [INC-016](../incident-index/README.md) and the [Stripe webhook test plan](../playbooks/stripe-webhook-test-plan.md). Includes the three-delivery sequence (happy path, duplicate-while-processing, timeout-then-reclaim).

## Planned (not yet built)

Do not link these until the files exist:

- Request lifecycle (browser -> middleware -> SSR auth -> RLS -> database) — planned.
- Cache invalidation flow after Server Actions — planned.
- Migration rollout and rollback sequence — planned.