# Zero-Downtime Rollout Checklist for Next.js + Supabase Production Deployments

Last verified: 2026-05-24

## Pre-Deploy

- [ ] Confirm current database backup freshness and restore test status.
- [ ] Confirm migration scripts are forward-compatible with previous app version.
- [ ] Confirm feature flags allow fallback behavior if new schema is partially adopted.
- [ ] Confirm Stripe webhook and auth callback URLs for preview and production.
- [ ] Confirm RLS policy changes are tested with anon/authenticated roles.

## Deploy Window

- [ ] Deploy additive database changes first.
- [ ] Deploy application code that can read old and new schema shape.
- [ ] Run canary traffic and inspect error rate, auth flow, and billing events.
- [ ] Watch runtime logs for cache invalidation and middleware redirect anomalies.
- [ ] Validate one end-to-end checkout and one auth refresh flow.

## Post-Deploy Verification

- [ ] Run `EXPLAIN ANALYZE` on top tenant-scoped queries.
- [ ] Verify `revalidatePath` or tag invalidation for changed routes.
- [ ] Verify webhook idempotency event table for duplicates.
- [ ] Verify RLS policies still enforce tenant isolation after migration.
- [ ] Publish release note with rollback trigger conditions.

## Rollback Trigger Thresholds

- Error rate exceeds baseline by agreed SLO margin.
- Auth refresh failures exceed threshold.
- Subscription state diverges from Stripe events.
- Query latency regression exceeds rollback budget.
