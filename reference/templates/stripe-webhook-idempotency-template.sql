-- Stripe webhook idempotency schema template for Supabase/PostgreSQL.
-- Last verified: 2026-05-24

create table if not exists public.stripe_webhook_events (
  id bigserial primary key,
  stripe_event_id text not null unique,
  event_type text not null,
  livemode boolean not null,
  payload jsonb not null,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  processing_error text
);

create index if not exists idx_stripe_webhook_events_received_at
  on public.stripe_webhook_events (received_at desc);

-- Usage pattern in handler:
-- 1) insert event id first (or upsert on conflict do nothing)
-- 2) if conflict -> skip (already processed)
-- 3) execute business mutation inside transaction
-- 4) set processed_at on success

-- Example idempotent insert:
-- insert into public.stripe_webhook_events (stripe_event_id, event_type, livemode, payload)
-- values ($1, $2, $3, $4)
-- on conflict (stripe_event_id) do nothing;

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
