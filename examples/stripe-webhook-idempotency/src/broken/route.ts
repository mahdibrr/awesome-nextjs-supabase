import { verifySignature } from '../lib/stripe-verify';
import type { WebhookDeps, WebhookRequest, WebhookResponse } from '../types';

/**
 * BROKEN handler — the INC-016 trap.
 *
 * Verifies the signature, records the event as 'received', then returns 200
 * WITHOUT awaiting the side effects and WITHOUT transitioning the state to
 * 'processed'. The side effects are fire-and-forget. Stripe sees 200 and stops
 * retrying. If this process exits (serverless freeze, crash, OOM, deploy) in
 * the gap between the 200 and the deferred side effect, business state is
 * silently wrong: no subscription row, event never marked processed, and
 * Stripe will not redeliver.
 *
 * This is exactly the failure mode described in
 *   reference/incident-index/README.md (INC-016)
 * and the diagram
 *   reference/diagrams/stripe-webhook-state-machine.md (the "Return 200 with
 *   side effects uncommitted is the INC-016 trap" note).
 */
export async function handleWebhook(
  req: WebhookRequest,
  deps: WebhookDeps,
): Promise<WebhookResponse> {
  const secret = deps.secret ?? process.env.STRIPE_WEBHOOK_SECRET ?? '';
  const sig = req.headers['stripe-signature'] ?? '';

  // INC-006: signature verification is still done correctly here — the bug is
  // downstream, in the state machine.
  if (!verifySignature(req.rawBody, sig, secret)) {
    return { status: 400, body: { error: 'invalid signature' } };
  }

  let event;
  try {
    event = JSON.parse(req.rawBody.toString('utf8'));
  } catch {
    return { status: 400, body: { error: 'invalid json' } };
  }

  // Record the event id (event-level dedup is present in the schema), but we
  // will NOT drive the state machine through claim -> commit -> processed.
  await deps.store.insertEvent(event.id as string, event);

  // === BUG: fire-and-forget the side effects. We do NOT await them and do NOT
  // mark the event processed before returning 200. ===========================
  void deps.sideEffects.applySubscription(event).catch(() => {
    /* swallow — the bug: we already told Stripe 200 */
  });

  // 200 sent immediately. State is still 'received'. Side effects uncommitted.
  return { status: 200, body: { received: true } };
}