// Shared types for the Stripe webhook idempotency example.
// Pinned to the state machine in
//   reference/templates/stripe-webhook-idempotency-template.sql
// and the diagram in
//   reference/diagrams/stripe-webhook-state-machine.md

export type WebhookState = 'received' | 'processing' | 'processed' | 'failed';

/**
 * A minimal view of a Stripe event. We only need the fields the handler reads.
 * The fixture in tests/fixtures/checkout_completed.json is a realistic
 * checkout.session.completed event with fake `evt_test_*` / `sub_test_*` ids.
 */
export interface StripeEvent {
  id: string;
  object: 'event';
  type: string;
  livemode: boolean;
  created: number;
  data: {
    object: Record<string, unknown>;
  };
}

export interface WebhookEventRow {
  stripe_event_id: string;
  state: WebhookState;
  processing_attempts: number;
  last_attempt_at: Date | null;
  processed_at: Date | null;
  payload: StripeEvent;
}

/**
 * Event-level idempotency store. The in-memory implementation
 * (src/lib/in-memory-store.ts) mirrors the SQL template's claim/commit
 * semantics, including the lease via `last_attempt_at` and the attempts cap.
 */
export interface WebhookStore {
  getEvent(id: string): Promise<WebhookEventRow | undefined>;
  insertEvent(id: string, payload: StripeEvent): Promise<WebhookEventRow>;
  /** Atomic claim. Returns the row if this caller acquired the right to run
   *  side effects (state in received/failed, OR processing with an expired
   *  lease and under the attempts cap). Returns undefined if not claimable
   *  (already processing with a live lease, already processed, or attempts
   *  exhausted). Bumps processing_attempts and sets last_attempt_at = now. */
  claim(id: string): Promise<WebhookEventRow | undefined>;
  markProcessed(id: string): Promise<void>;
  markFailed(id: string): Promise<void>;
}

/**
 * Business side effects. Must be independently idempotent — the store's unique
 * (stripe_event_id, side_effect_name) constraint makes a duplicate INSERT throw,
 * which the handler treats as an idempotent no-op. The in-memory implementation
 * stages the mutation and only commits it when the store commits (markProcessed),
 * mirroring a real Postgres transaction.
 */
export interface SideEffects {
  applySubscription(event: StripeEvent): Promise<void>;
}

export interface WebhookRequest {
  rawBody: Buffer;
  headers: Record<string, string>;
}

export interface WebhookResponse {
  status: number;
  body: unknown;
}

export interface WebhookDeps {
  store: WebhookStore;
  sideEffects: SideEffects;
  /**
   * Optional clock. The route itself is clock-agnostic; the store uses its own
   * configured `now` so tests can advance time deterministically without real
   * sleeps. Kept on deps for signature compliance with the documented contract.
   */
  now?: () => Date;
  /** Lease window for the `processing` state. Owned by the store in practice. */
  leaseMs?: number;
  /** Max attempts before claim refuses and hands off to reconciliation. */
  maxAttempts?: number;
  /** Stripe webhook secret. Falls back to process.env.STRIPE_WEBHOOK_SECRET. */
  secret?: string;
}