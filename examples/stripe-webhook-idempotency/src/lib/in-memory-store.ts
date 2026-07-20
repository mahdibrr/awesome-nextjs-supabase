import type {
  SideEffects,
  StripeEvent,
  WebhookEventRow,
  WebhookStore,
} from '../types';

export interface InMemoryStoreOptions {
  now: () => Date;
  leaseMs: number;
  maxAttempts: number;
}

interface SubscriptionRecord {
  userId: string;
  subscriptionId: string;
  status: string;
}

/**
 * In-memory WebhookStore mirroring the SQL template in
 *   supabase/migrations/0001_webhook_events.sql
 *
 * claim/commit semantics:
 *  - state in {received, failed} -> claimable (if under attempts cap). Sets
 *    state='processing', attempts++, last_attempt_at = now().
 *  - state='processing' with (now - last_attempt_at) > leaseMs -> reclaimable
 *    (if under attempts cap). Bumps attempts, refreshes last_attempt_at, stays
 *    in 'processing'.
 *  - state='processed' or attempts >= cap -> not claimable (returns undefined).
 *
 * To simulate a real Postgres transaction, side-effect mutations are STAGED by
 * InMemorySideEffects.applySubscription and only COMMITTED to the visible
 * maps/counters when markProcessed is called. markFailed discards staged
 * mutations (rollback). This makes the lease-reclaim scenario honest: a
 * crashed attempt that staged but never committed leaves nothing behind, so a
 * reclaim can re-run the side effects cleanly.
 */
export class InMemoryStore implements WebhookStore {
  private readonly events = new Map<string, WebhookEventRow>();

  /** Staged (uncommitted) side-effect mutations, keyed by event id. */
  public readonly staged = new Map<string, SubscriptionRecord>();

  /** Committed side-effect mutations, keyed by event id. Mirrors the unique
   *  (stripe_event_id, side_effect_name) constraint: an event id appears at
   *  most once. */
  public readonly committedSubscriptions = new Map<string, SubscriptionRecord>();

  /** Set of `${eventId}:applySubscription` that have committed. Mirrors the
   *  unique constraint; a second commit is a no-op. */
  public readonly committedSideEffects = new Set<string>();

  /** Count of committed subscription upserts. Tests assert on this to detect
   *  duplicates (INC-007) and missed writes (INC-016). */
  public subscriptionsUpserted = 0;

  constructor(private readonly opts: InMemoryStoreOptions) {}

  private clone(row: WebhookEventRow): WebhookEventRow {
    return {
      ...row,
      last_attempt_at: row.last_attempt_at ? new Date(row.last_attempt_at) : null,
      processed_at: row.processed_at ? new Date(row.processed_at) : null,
    };
  }

  async getEvent(id: string): Promise<WebhookEventRow | undefined> {
    const row = this.events.get(id);
    return row ? this.clone(row) : undefined;
  }

  async insertEvent(id: string, payload: StripeEvent): Promise<WebhookEventRow> {
    const existing = this.events.get(id);
    if (existing) return this.clone(existing);
    const row: WebhookEventRow = {
      stripe_event_id: id,
      state: 'received',
      processing_attempts: 0,
      last_attempt_at: null,
      processed_at: null,
      payload,
    };
    this.events.set(id, row);
    return this.clone(row);
  }

  async claim(id: string): Promise<WebhookEventRow | undefined> {
    const row = this.events.get(id);
    if (!row) return undefined;
    const now = this.opts.now();

    if (row.state === 'received' || row.state === 'failed') {
      if (row.processing_attempts >= this.opts.maxAttempts) return undefined;
      row.state = 'processing';
      row.processing_attempts += 1;
      row.last_attempt_at = now;
      return this.clone(row);
    }

    if (row.state === 'processing') {
      // Lease: if last_attempt_at is older than leaseMs, treat as crashed.
      const stale =
        row.last_attempt_at !== null &&
        now.getTime() - row.last_attempt_at.getTime() > this.opts.leaseMs;
      if (stale) {
        if (row.processing_attempts >= this.opts.maxAttempts) return undefined;
        row.processing_attempts += 1;
        row.last_attempt_at = now;
        return this.clone(row);
      }
      // Someone else owns it and the lease is live -> do NOT run side effects.
      return undefined;
    }

    // state === 'processed' -> not claimable; the route short-circuits earlier,
    // but defend in depth.
    return undefined;
  }

  async markProcessed(id: string): Promise<void> {
    const row = this.events.get(id);
    if (!row) return;
    // Commit staged side effects (the "transaction" commits).
    const staged = this.staged.get(id);
    if (staged) {
      const key = `${id}:applySubscription`;
      if (!this.committedSideEffects.has(key)) {
        this.committedSideEffects.add(key);
        this.committedSubscriptions.set(id, staged);
        this.subscriptionsUpserted += 1;
      }
      this.staged.delete(id);
    }
    row.state = 'processed';
    row.processed_at = this.opts.now();
  }

  async markFailed(id: string): Promise<void> {
    const row = this.events.get(id);
    if (!row) return;
    // Roll back staged side effects (the "transaction" aborted).
    this.staged.delete(id);
    row.state = 'failed';
  }
}

/**
 * Side-effect implementation. `applySubscription` stages the mutation into the
 * store; the store commits it on markProcessed. If the same event is replayed
 * after commit, the committed-side-effects set short-circuits to a no-op
 * (mirroring the handler catching a unique-constraint violation).
 */
export class InMemorySideEffects implements SideEffects {
  constructor(private readonly store: InMemoryStore) {}

  async applySubscription(event: StripeEvent): Promise<void> {
    const key = `${event.id}:applySubscription`;

    // Already committed? Idempotent no-op. This is the handler's try/catch on a
    // unique-constraint violation: the INSERT threw, we treat it as success.
    if (this.store.committedSideEffects.has(key)) return;

    // Already staged in the current attempt? Don't double-stage.
    if (this.store.staged.has(event.id)) return;

    const obj = event.data.object as Record<string, unknown>;
    const metadata = (obj.metadata as Record<string, unknown> | undefined) ?? {};
    const staged: SubscriptionRecord = {
      userId: String(metadata.user_id ?? 'user_test'),
      // checkout.session.completed: the subscription id lives under `subscription`.
      subscriptionId: String(obj.subscription ?? obj.id ?? 'sub_test'),
      status: String(obj.status ?? 'active'),
    };
    this.store.staged.set(event.id, staged);
  }
}