# Migration Rollback Playbook for Next.js + Supabase Production Incidents

Last verified: 2026-05-24

## Objective

Recover service quickly when schema rollout causes auth failures, billing divergence, or query regressions.

## Trigger Conditions

- Elevated error rate tied to migrated tables.
- RLS policy failures after schema deploy.
- Checkout or subscription reconciliation failures.
- Query latency spike beyond rollback budget.

## Rollback Sequence

1. Pause risky background jobs and non-essential writes.
2. Enable feature-flag fallback paths in application layer.
3. Execute backward migration script if data-safe.
4. Re-run policy and index verification checks.
5. Validate auth refresh, RLS reads/writes, and Stripe webhook ingestion.
6. Resume traffic gradually and monitor error budget.

## Verification Checklist

- Auth: SSR session survives refresh.
- RLS: tenant isolation and expected read/write behavior.
- Billing: no duplicate or missing subscription events.
- Caching: invalidation paths return fresh state.
- Observability: error rate and latency return to baseline.

## Post-Incident Notes

- Capture root cause and migration assumptions that failed.
- Record lock duration and rollback duration.
- Add incident entry to incident index with prevention controls.
