import { verifySignature } from '../lib/stripe-verify';
import type { WebhookDeps, WebhookRequest, WebhookResponse } from '../types';

/**
 * FIXED handler — the state machine from
 *   reference/templates/stripe-webhook-idempotency-template.sql
 * and
 *   reference/diagrams/stripe-webhook-state-machine.md
 *
 * 1. Verify signature (INC-006).
 * 2. Idempotent insert of the event id.
 * 3. If the event is already 'processed', return 200 without re-running side
 *    effects (idempotent replay after success — Test Plan scenario 1).
 * 4. Atomically claim the event. If claim returns undefined (someone else is
 *    processing with a live lease, or the attempts cap is hit), return NON-2xx
 *    so Stripe retries (INC-007: no concurrent side effects, no duplicates).
 * 5. Run side effects inside the "transaction". The in-memory store stages on
 *    applySubscription and commits on markProcessed.
 * 6. On success: markProcessed THEN return 200 (INC-016: 200 only after commit).
 *    On failure: markFailed and return 500 (Stripe retries; lease reclaim or
 *    the reconciliation backfill eventually completes it — INC-012).
 */
export async function handleWebhook(
  req: WebhookRequest,
  deps: WebhookDeps,
): Promise<WebhookResponse> {
  const secret = deps.secret ?? process.env.STRIPE_WEBHOOK_SECRET ?? '';
  const sig = req.headers['stripe-signature'] ?? '';

  if (!verifySignature(req.rawBody, sig, secret)) {
    return { status: 400, body: { error: 'invalid signature' } };
  }

  let event;
  try {
    event = JSON.parse(req.rawBody.toString('utf8'));
  } catch {
    return { status: 400, body: { error: 'invalid json' } };
  }

  const eventId = event.id as string;

  // Idempotent insert (on conflict do nothing).
  await deps.store.insertEvent(eventId, event);

  // Idempotent replay after success: already processed -> 200, no side effects.
  const existing = await deps.store.getEvent(eventId);
  if (existing?.state === 'processed') {
    return { status: 200, body: { ok: true, deduplicated: true } };
  }

  // Atomic claim. Undefined means: another delivery is processing with a live
  // lease, OR the attempts cap is exhausted. Either way, do NOT run side
  // effects; return non-2xx so Stripe retries.
  const claimed = await deps.store.claim(eventId);
  if (!claimed) {
    return {
      status: 500,
      body: { error: 'event already processing or attempts exhausted' },
    };
  }

  // Side effects + commit. On success, markProcessed THEN 200. On throw,
  // markFailed and 500 so Stripe retries (lease reclaim or backfill finishes it).
  try {
    await deps.sideEffects.applySubscription(event);
    await deps.store.markProcessed(eventId);
    return { status: 200, body: { ok: true } };
  } catch (err) {
    await deps.store.markFailed(eventId);
    return {
      status: 500,
      body: { error: 'side effect failed', message: (err as Error).message },
    };
  }
}