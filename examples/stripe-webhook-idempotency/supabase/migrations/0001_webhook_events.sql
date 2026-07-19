-- Stripe webhook idempotency schema for Supabase/PostgreSQL.
-- Adapted from reference/templates/stripe-webhook-idempotency-template.sql
-- (last verified 2026-07-08). This file is the production artifact; the tests
-- use src/lib/in-memory-store.ts which mirrors these exact semantics so the
-- suite runs with zero external services.
--
-- State machine:
--   received   -> row inserted, side effects not yet attempted
--   processing -> a worker has claimed the event and is running side effects
--   processed  -> side effects committed successfully
--   failed     -> a side effect raised; safe to retry
--
-- Lease: a `processing` row whose `last_attempt_at` is older than the
-- worst-case handler runtime is reclaimable (treat as crashed). This is the
-- `processing -> processing` self-loop in
-- reference/diagrams/stripe-webhook-state-machine.md, not a schema change.
--
-- Attempts cap: once processing_attempts passes the cap, stop reclaiming and
-- alert. Recovery belongs to the reconciliation backfill (Stripe API), not to
-- Stripe retries — see reference/playbooks/stripe-webhook-test-plan.md.

create table if not exists public.stripe_webhook_events (
  id bigserial primary key,
  stripe_event_id text not null unique,
  event_type text not null,
  livemode boolean not null,
  payload jsonb not null,
  state text not null default 'received'
    check (state in ('received', 'processing', 'processed', 'failed')),
  received_at timestamptz not null default now(),
  processing_attempts int not null default 0,
  last_attempt_at timestamptz,
  processed_at timestamptz,
  processing_error text
);

create index if not exists idx_stripe_webhook_events_received_at
  on public.stripe_webhook_events (received_at desc);

create index if not exists idx_stripe_webhook_events_state
  on public.stripe_webhook_events (state, received_at desc);

-- Handler usage (event-level idempotency):
-- 1) insert event id first with state='received' (on conflict do nothing).
-- 2) if conflict -> SELECT the existing row, check its state
--      - 'processed'  -> return 200 immediately (duplicate, already done)
--      - 'received' or 'failed' -> claim it
-- 3) claim step (atomic, before side effects):
--      update public.stripe_webhook_events
--         set state = 'processing',
--             processing_attempts = processing_attempts + 1,
--             last_attempt_at = now()
--       where stripe_event_id = $1
--         and state in ('received', 'failed')
--         and processing_attempts < $2  -- attempts cap, e.g. 5
--      returning id;
--    Lease reclaim (processing row with stale last_attempt_at):
--      update public.stripe_webhook_events
--         set processing_attempts = processing_attempts + 1,
--             last_attempt_at = now()
--       where stripe_event_id = $1
--         and state = 'processing'
--         and last_attempt_at < now() - interval '<lease window>'
--         and processing_attempts < $2
--      returning id;
--    If neither returns a row -> do NOT run side effects. Return non-2xx so
--    Stripe retries (INC-007: prevents concurrent duplicates).
-- 4) BEGIN tx -> side effects -> COMMIT (side-effect tables have their own
--    unique (stripe_event_id, side_effect_name) constraint, so a retry after a
--    crashed commit is an idempotent no-op).
-- 5) UPDATE state='processed', processed_at=now()  -- only AFTER commit
-- 6) on side-effect failure: ROLLBACK, UPDATE state='failed', processing_error.
-- 7) return 200 only when state moved to 'processed' on THIS delivery.

-- Per-side-effect idempotency table: one row per (event, side effect) that
-- has committed. Re-execution hits the unique constraint and the handler
-- treats the thrown unique-violation as an idempotent success.
create table if not exists public.stripe_webhook_side_effects (
  id bigserial primary key,
  stripe_event_id text not null,
  side_effect_name text not null,
  applied_at timestamptz not null default now(),
  unique (stripe_event_id, side_effect_name),
  foreign key (stripe_event_id)
    references public.stripe_webhook_events (stripe_event_id) on delete cascade
);

create index if not exists idx_stripe_webhook_side_effects_event
  on public.stripe_webhook_side_effects (stripe_event_id);

-- Business-state table (the thing the webhook mutates). INC-016 is "200 OK
-- but no row here" (or a duplicate row). The unique constraints above make
-- retries safe; the state machine above makes 200 mean "committed".
create table if not exists public.billing_subscriptions (
  id bigserial primary key,
  user_id uuid not null,
  stripe_customer_id text not null,
  stripe_subscription_id text not null unique,
  status text not null,
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists idx_billing_subscriptions_user_id
  on public.billing_subscriptions (user_id);