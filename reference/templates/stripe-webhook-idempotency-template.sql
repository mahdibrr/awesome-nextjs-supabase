-- Stripe webhook idempotency schema template for Supabase/PostgreSQL.
-- Last verified: 2026-07-08
--
-- This template gives you event-level deduplication (INC-006, INC-007) and
-- the minimum schema needed to detect partial business state (INC-016):
-- a row in `received` does not mean the side effects committed.
--
-- The pattern is: track processing state, not just "seen". When the same
-- event id is replayed, the handler reads the current state and either
-- skips (already processed) or resumes (stuck in received) rather than
-- blindly re-running business logic.

create table if not exists public.stripe_webhook_events (
  id bigserial primary key,
  stripe_event_id text not null unique,
  event_type text not null,
  livemode boolean not null,
  payload jsonb not null,
  -- State machine for the event itself, independent of the side effects.
  --   received   -> row inserted, side effects not yet attempted
  --   processing -> a worker has claimed the event and is running side effects
  --   processed  -> side effects committed successfully
  --   failed     -> a side effect raised; safe to retry
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

-- Index for the most common operational queries:
-- "show me events that are stuck" or "show me events that failed".
create index if not exists idx_stripe_webhook_events_state
  on public.stripe_webhook_events (state, received_at desc);

-- Usage pattern in handler (event-level idempotency):
-- 1) insert event id first with state='received' (or upsert on conflict do nothing)
-- 2) if conflict -> SELECT the existing row, check its state
--      - 'processed'  -> return 200 immediately (duplicate, already done)
--      - 'received' or 'failed' -> claim it (UPDATE state='processing',
--        processing_attempts = processing_attempts + 1, last_attempt_at = now())
-- 3) run business side effects inside a transaction
-- 4) commit transaction
-- 5) UPDATE state='processed', processed_at=now()  -- only AFTER commit
-- 6) on side-effect failure, ROLLBACK the transaction and
--    UPDATE state='failed', processing_error=<message>
-- 7) return 200 only when state moved to 'processed' on this delivery

-- Example idempotent insert that also claims the event:
-- insert into public.stripe_webhook_events (stripe_event_id, event_type, livemode, payload)
-- values ($1, $2, $3, $4)
-- on conflict (stripe_event_id) do nothing
-- returning id;
-- -- if no row returned -> existing event, fetch and branch on its state

-- Example claim step (after the insert, before side effects):
-- update public.stripe_webhook_events
--    set state = 'processing',
--        processing_attempts = processing_attempts + 1,
--        last_attempt_at = now()
--  where stripe_event_id = $1
--    and state in ('received', 'failed')
--  returning id;
-- -- if no row returned -> someone else is processing, or already processed

-- Example completion step (after side effects commit):
-- update public.stripe_webhook_events
--    set state = 'processed',
--        processed_at = now()
--  where stripe_event_id = $1;

-- Business-state idempotency (INC-016) lives in the side-effect tables,
-- not in this one. For each business mutation (entitlement grant, ledger
-- row, fulfillment, subscription update) use a unique constraint on
-- (stripe_event_id, side_effect_name) so that re-execution is a no-op
-- rather than a duplicate. The handler is safe to retry ONLY if the side
-- effects are independently idempotent.

-- Subscription state table baseline.
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
