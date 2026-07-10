# Stripe Webhook Test Plan for Next.js + Supabase

Last verified: 2026-07-08

> Companion to [INC-016](../incident-index/README.md). When a webhook handler passes the obvious tests (one event, 200 OK) but the production data drifts, the problem is almost always one of the six scenarios below. This plan enumerates them and gives the minimum assertions each one needs.

## Objective

Validate that a Stripe webhook handler is safe to retry, safe to interleave, and safe to interrupt — not just that it returns 200 OK on a single happy-path event.

A handler is considered correct only when **final business state** matches the expected outcome for every scenario, not when the HTTP response is green.

## Prerequisites

- A testable Stripe webhook handler (Next.js Route Handler, Supabase Edge Function, or equivalent).
- A test database (Supabase local stack or a dedicated test project).
- A way to replay the same Stripe event with the same `event.id` (Stripe Dashboard, `stripe trigger`, or a stored fixture).
- A way to assert state in `billing_subscriptions`, `stripe_webhook_events`, and any business side-effect tables (entitlements, ledger, fulfillment).

## Scenarios

### 1. Same event id replayed

Deliver the same `event.id` twice in a row from a clean state.

**Expected outcome:**
- The handler returns 200 for both deliveries.
- The second delivery does not duplicate any side effect.
- `stripe_webhook_events` contains exactly one row for that `event.id`.

**Assertion target:** count of business rows (e.g. subscription rows, entitlement grants) before and after the replay — must match.

### 2. Concurrent duplicate delivery

Deliver the same `event.id` twice in parallel (two HTTP requests, no ordering guarantee).

**Expected outcome:**
- Exactly one delivery performs the side effects.
- The other delivery returns 200 but observes the same final state.
- No partial state (e.g. ledger row inserted but entitlement not yet granted).

**Assertion target:** a unique constraint on `stripe_event_id` rejects the second insert. If the database lacks the constraint, the handler must perform a `SELECT ... FOR UPDATE` or equivalent check inside the same transaction as the side effect.

### 3. Timeout / 5xx followed by retry

Force the handler to time out (sleep longer than the platform limit, or stub a downstream call to throw) **after** the event is recorded but **before** the side effects complete. Stripe will retry the same `event.id`.

**Expected outcome:**
- The first delivery either:
  - returns 5xx, leaving the event in a non-final state, OR
  - returns 200 only after the side effects have committed.
- The retry completes the side effects (or correctly skips them as already-done).
- Final business state is correct.

**Assertion target:** the test fails if the first delivery returned 200 but the side effects did not commit. This is the "duplicate 200" failure mode INC-016 describes.

### 4. Failure after event insert but before business side effect

Simulate a crash (or a thrown exception) between the `INSERT INTO stripe_webhook_events` and the side-effect mutation (entitlement grant, ledger row, fulfillment call).

**Expected outcome:**
- The handler does not return 200.
- On retry, the handler can either:
  - detect the partial state and complete the side effects, OR
  - re-execute them safely because each side effect is independently idempotent.
- No side effect is left half-done.

**Assertion target:** each business mutation has its own idempotency key (e.g. unique on `(stripe_event_id, side_effect_name)`), so re-execution is a no-op rather than a duplicate.

### 5. Out-of-order event delivery

Stripe does not guarantee event ordering under retries. Deliver `customer.subscription.updated` **before** `customer.subscription.created` for the same subscription.

**Expected outcome:**
- Final subscription state matches what the *latest* event in event-time order would have produced.
- No crash, no skipped update, no contradictory state.

**Assertion target:** handler reads previous state from the database rather than assuming monotonic event delivery. Test by replaying events in `created → updated → deleted` order, then in `updated → created → deleted`, and verifying identical final state.

### 6. Business-state assertions, not just HTTP 200

For every scenario above, the test must assert **business state** in the database, not just the HTTP response code.

**Minimum assertions per scenario:**

| What to assert | Why |
| --- | --- |
| Row counts on side-effect tables | Detects duplicates and missed writes. |
| Status field of affected rows | Detects stale or out-of-order updates. |
| Sum of monetary fields (ledger, balance) | Detects double charges and missed refunds. |
| `state` column of `stripe_webhook_events` | Confirms the state machine reaches `processed`, not just that a row exists. |

A test suite that only asserts `response.status === 200` will pass on a handler that is silently corrupting business state. INC-016 is exactly this failure.

## Test Harness Notes

- Use the Stripe CLI (`stripe trigger <event_type>`) to generate real signed events in local development.
- For idempotency tests, the Stripe CLI's `--skip-verify` flag and a captured event payload are sufficient — the goal is to deliver the *same* `event.id`, not to simulate every Stripe edge.
- For concurrency tests, two parallel `fetch` calls to the local handler with the same fixture are usually enough to expose the race.
- For timeout tests, the easiest pattern is to inject a delay or throw in the side-effect step and let the platform timeout window elapse.

## Verification Checklist

- All six scenarios pass in CI.
- The test suite asserts business state, not just HTTP responses.
- The handler returns 200 only after side effects commit.
- A unique constraint on `stripe_event_id` is in place (see the [Stripe webhook idempotency template](../templates/stripe-webhook-idempotency-template.sql)).
- Each side-effect table has its own idempotency key for `stripe_event_id` references.

## Post-Test Notes

If a scenario fails, capture:
- The handler code path that misbehaved.
- The exact database state at the moment of failure.
- The retry outcome.
- The fix applied (and the test that now covers it).

These notes become the next incident row in the [Incident Index](../incident-index/README.md).
