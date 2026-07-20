# Stripe Webhook Idempotency — Runnable Example

A self-contained, dependency-light example demonstrating the four Stripe webhook incidents that bite in production: signature verification, duplicate rows from retries, Edge Function timeouts, and the flagship trap — **200 OK returned before business state commits**.

Runnable with `npm install && npm test`. No real Stripe keys, no real Postgres, no network. Vitest only.

## What this demonstrates

| Incident | Failure mode | What the example shows |
| --- | --- | --- |
| [INC-006](../../reference/incident-index/README.md) | Webhook signature verification failed (wrong secret, transformed body, env mismatch) | Real HMAC-SHA256 verify over the raw body with constant-time compare; a mismatched secret yields 400. |
| [INC-007](../../reference/incident-index/README.md) | Duplicate subscription rows from retries (no idempotency store for event IDs) | Atomic claim returns `undefined` while another delivery is processing -> second delivery returns non-2xx so Stripe retries, side effects run exactly once. |
| [INC-012](../../reference/incident-index/README.md) | Edge Function webhook processing times out (long-running logic, no queue handoff) | Lease reclaim via `last_attempt_at`: a `processing` row whose lease has expired is reclaimable; an attempts cap hands off to a reconciliation backfill instead of retrying forever. |
| [INC-016](../../reference/incident-index/README.md) | Webhook returns 200 OK but business state is wrong (event marked processed before side effects commit) | The `broken/route.ts` returns 200 before committing; the `fixed/route.ts` returns 200 only after `markProcessed`. |

## The bug (INC-016)

`src/broken/route.ts` verifies the signature, inserts the event as `received`, then **returns 200 immediately** with the side effects fire-and-forget. Stripe sees 200 and stops retrying. If the process exits in the gap between the 200 and the deferred side effect (serverless freeze, crash, OOM, deploy), business state is silently wrong:

- the event row is still `received`, never `processed`;
- no subscription row was committed;
- Stripe will not redeliver, because it got a 2xx.

A test suite that only asserts `response.status === 200` passes on this handler. The [Stripe webhook test plan](../../reference/playbooks/stripe-webhook-test-plan.md) exists precisely because this is the failure mode that a green dashboard hides.

## The fix

`src/fixed/route.ts` drives the state machine from the [idempotency template](../../reference/templates/stripe-webhook-idempotency-template.sql) and the [state-machine diagram](../../reference/diagrams/stripe-webhook-state-machine.md):

1. Verify the signature (INC-006).
2. Idempotent insert of the event id.
3. If the event is already `processed`, return 200 without re-running side effects (idempotent replay after success).
4. **Claim** atomically. If claim returns `undefined` (someone else is processing with a live lease, or the attempts cap is hit), return **non-2xx** so Stripe retries (INC-007: no concurrent side effects, no duplicates).
5. Run side effects inside the "transaction". The in-memory store stages on `applySubscription` and commits on `markProcessed`.
6. On success: `markProcessed` **then** return 200 (INC-016: 200 only after commit). On failure: `markFailed` and return 500 (Stripe retries; lease reclaim or the reconciliation backfill eventually completes it — INC-012).

The lease is driven by `last_attempt_at`: a `processing` row older than the lease window is reclaimable, which is the `processing -> processing` self-loop in the diagram (not a schema change). After the attempts cap, claim refuses and the event is left for a reconciliation backfill from the Stripe API — it is not retried forever.

## Run the tests

```bash
cd examples/stripe-webhook-idempotency
npm install
npm test
```

`npm install` pulls in only `vitest`. `npm test` runs the suite in `tests/idempotency.test.ts`:

1. broken route returns 200 without committing side effects (INC-016)
2. fixed route returns 200 only after side effects commit
3. duplicate while processing returns non-2xx; side effects run once (INC-007)
4. idempotent replay after success returns 200 without re-running side effects
5. lease reclaim after crash mid-processing (INC-012)
6. attempts cap: after N failed attempts, claim refuses and returns 500
7. signature verification rejects a bad signature (INC-006)

The store uses an injected `now()` so the lease test advances time deterministically — no real sleeps, no fake-timer juggling.

## File map

| File | Role |
| --- | --- |
| `src/types.ts` | `WebhookStore` + `SideEffects` interfaces, `WebhookState` type. |
| `src/broken/route.ts` | The INC-016 bug: 200 before side effects commit. |
| `src/fixed/route.ts` | The correction: claim -> side effects in tx -> markProcessed -> 200. |
| `src/lib/in-memory-store.ts` | In-memory `WebhookStore` mirroring the SQL claim/commit semantics, including lease via `last_attempt_at` and the attempts cap. Side effects are staged on `applySubscription` and committed on `markProcessed` to simulate a real transaction. |
| `src/lib/stripe-verify.ts` | Real HMAC-SHA256 over the raw body with a constant-time compare. Test-only `test_secret`/`test_sig` shortcut gated on `NODE_ENV=test`. |
| `tests/idempotency.test.ts` | The suite; uses an in-memory store + injected clock. |
| `tests/fixtures/checkout_completed.json` | A realistic `checkout.session.completed` event with fake `evt_test_*` ids. |
| `supabase/migrations/0001_webhook_events.sql` | The production SQL (adapted from the template). Tests do not run it; the in-memory store mirrors it. |

## Production notes

- **Real signature verify.** `src/lib/stripe-verify.ts` implements the actual Stripe scheme (`t=...,v1=...` over `<timestamp>.<rawBody>`). In Next.js, read the raw body as a `Buffer`/`ArrayBuffer` before any JSON parse — transforming the body breaks the signature (INC-006). Keep the test-only `test_secret`/`test_sig` shortcut out of production by setting `NODE_ENV=production`.
- **Wrap side effects in a real Postgres transaction.** The in-memory store stages on `applySubscription` and commits on `markProcessed` to mirror `BEGIN ... COMMIT`. In production, `sideEffects.applySubscription` and `UPDATE state='processed'` should be in the same transaction (or the side-effect commit must precede the `processed` update), so the state never lies.
- **Unique `(stripe_event_id, side_effect_name)`.** Each business mutation (entitlement grant, ledger row, subscription upsert) needs its own idempotency key. A retry that hits a duplicate INSERT throws a unique-violation; the handler catches that and treats it as an idempotent no-op. Without this, retries after a partial commit duplicate business state.
- **Return non-2xx while processing.** If a duplicate delivery arrives while the first is still processing (lease live), the handler returns 500. Stripe retries; the first delivery completes; the retry sees `processed` and short-circuits. Returning 200 here is what creates duplicate subscription rows (INC-007).
- **Backfill from the Stripe API past the attempts cap.** Once `processing_attempts` hits the cap, the handler stops reclaiming and returns 500. A separate reconciliation job reads the Stripe API for events in `failed`/stale-`processing` and either completes them or files them for manual review. Do not let Stripe retry forever.
- **Keep the handler short.** For Supabase Edge Functions specifically (INC-012), hand long-running work to a queue and keep the webhook handler idempotent and fast. The state machine here is what makes the handoff safe.

## References

- [Stripe webhook idempotency template (SQL)](../../reference/templates/stripe-webhook-idempotency-template.sql)
- [Stripe webhook state machine (diagram)](../../reference/diagrams/stripe-webhook-state-machine.md)
- [Stripe webhook test plan (playbook)](../../reference/playbooks/stripe-webhook-test-plan.md)
- [Incident index](../../reference/incident-index/README.md)