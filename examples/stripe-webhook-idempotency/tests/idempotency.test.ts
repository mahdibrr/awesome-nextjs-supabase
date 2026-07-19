import { describe, it, expect, beforeEach } from 'vitest';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

import { InMemoryStore, InMemorySideEffects } from '../src/lib/in-memory-store';
import { handleWebhook as brokenHandleWebhook } from '../src/broken/route';
import { handleWebhook as fixedHandleWebhook } from '../src/fixed/route';
import { signBody } from '../src/lib/stripe-verify';
import type { SideEffects, StripeEvent, WebhookDeps } from '../src/types';

const __dirname = dirname(fileURLToPath(import.meta.url));
const fixture = JSON.parse(
  readFileSync(join(__dirname, 'fixtures/checkout_completed.json'), 'utf8'),
) as StripeEvent;

const LEASE_MS = 1000;
const MAX_ATTEMPTS = 5;

function makeReq(event: StripeEvent) {
  return {
    rawBody: Buffer.from(JSON.stringify(event)),
    headers: { 'stripe-signature': 'test_sig' },
  };
}

function makeDeps(
  store: InMemoryStore,
  sideEffects: SideEffects,
  now: () => Date,
): WebhookDeps {
  return {
    store,
    sideEffects,
    now,
    leaseMs: LEASE_MS,
    maxAttempts: MAX_ATTEMPTS,
    secret: 'test_secret',
  };
}

describe('Stripe webhook idempotency', () => {
  let nowMs: number;
  let now: () => Date;
  let store: InMemoryStore;
  let sideEffects: InMemorySideEffects;

  beforeEach(() => {
    nowMs = 1_700_000_000_000; // deterministic epoch; tests advance via `advance`
    now = () => new Date(nowMs);
    store = new InMemoryStore({ now, leaseMs: LEASE_MS, maxAttempts: MAX_ATTEMPTS });
    sideEffects = new InMemorySideEffects(store);
  });

  const advance = (ms: number) => {
    nowMs += ms;
  };

  it('1. broken route returns 200 without committing side effects (INC-016)', async () => {
    const req = makeReq(fixture);
    const res = await brokenHandleWebhook(req, makeDeps(store, sideEffects, now));

    // The trap: Stripe sees 200 and stops retrying...
    expect(res.status).toBe(200);

    // ...but the event is NOT processed and no subscription was committed. If the
    // process exits now, business state is wrong and Stripe will not redeliver.
    const row = await store.getEvent(fixture.id);
    expect(row?.state).not.toBe('processed');
    expect(row?.state).toBe('received');
    expect(store.subscriptionsUpserted).toBe(0);
    expect(store.committedSubscriptions.has(fixture.id)).toBe(false);
  });

  it('2. fixed route returns 200 only after side effects commit', async () => {
    const req = makeReq(fixture);
    const res = await fixedHandleWebhook(req, makeDeps(store, sideEffects, now));

    expect(res.status).toBe(200);

    const row = await store.getEvent(fixture.id);
    expect(row?.state).toBe('processed');
    expect(row?.processing_attempts).toBe(1);
    expect(row?.processed_at).not.toBeNull();
    expect(store.subscriptionsUpserted).toBe(1);
    expect(store.committedSubscriptions.get(fixture.id)).toBeDefined();
    expect(store.committedSubscriptions.get(fixture.id)?.subscriptionId).toBe(
      'sub_test_001',
    );
  });

  it('3. duplicate while processing returns non-2xx — side effects run once (INC-007)', async () => {
    // First delivery claims and then blocks inside applySubscription on a
    // deferred. While it is parked in 'processing', a second delivery of the
    // same event id must NOT run side effects and must return non-2xx so Stripe
    // retries instead of duplicating business state.
    let resolveSlow: () => void = () => {};
    const slowPromise = new Promise<void>((r) => {
      resolveSlow = r;
    });
    let enteredSlow = () => {};
    const slowStarted = new Promise<void>((r) => {
      enteredSlow = r;
    });

    const slowSideEffects: SideEffects = {
      applySubscription: async (event) => {
        enteredSlow(); // signal: claim has happened, we are inside applySubscription
        await slowPromise;
        await sideEffects.applySubscription(event);
      },
    };

    const req = makeReq(fixture);

    // Start the first delivery. It will claim, then park on slowPromise.
    const p1 = fixedHandleWebhook(req, makeDeps(store, slowSideEffects, now));

    // Wait until the first delivery has actually claimed and entered the side
    // effect. At this point the row is state='processing', attempts=1.
    await slowStarted;

    // Fire the same event a second time. The row is 'processing' with a live
    // lease (no time has passed) -> claim returns undefined -> 500.
    const res2 = await fixedHandleWebhook(
      makeReq(fixture),
      makeDeps(store, sideEffects, now),
    );
    expect(res2.status).toBeGreaterThanOrEqual(500);
    expect(res2.status).toBeLessThan(600);

    // Let the first delivery finish. It commits the side effects.
    resolveSlow();
    const res1 = await p1;
    expect(res1.status).toBe(200);

    // Exactly one subscription committed, despite two deliveries.
    expect(store.subscriptionsUpserted).toBe(1);
    expect(store.committedSubscriptions.has(fixture.id)).toBe(true);

    const row = await store.getEvent(fixture.id);
    expect(row?.state).toBe('processed');
    expect(row?.processing_attempts).toBe(1);
  });

  it('4. idempotent replay after success returns 200 without re-running side effects', async () => {
    const req = makeReq(fixture);
    const res1 = await fixedHandleWebhook(req, makeDeps(store, sideEffects, now));
    expect(res1.status).toBe(200);
    expect(store.subscriptionsUpserted).toBe(1);

    // Stripe redelivers the same event id after a success (this happens in
    // production). The handler must see state='processed' and short-circuit.
    const res2 = await fixedHandleWebhook(
      makeReq(fixture),
      makeDeps(store, sideEffects, now),
    );
    expect(res2.status).toBe(200);

    // Side effects NOT re-applied.
    expect(store.subscriptionsUpserted).toBe(1);

    const row = await store.getEvent(fixture.id);
    expect(row?.state).toBe('processed');
    expect(row?.processing_attempts).toBe(1); // not reclaimed
  });

  it('5. lease reclaim after crash mid-processing (INC-012)', async () => {
    // Simulate a crash mid-processing: insert + claim directly, then leave the
    // row at 'processing' with a stale last_attempt_at and never call
    // markProcessed. This is exactly the "process crashes (no rollback)"
    // branch in the state-machine diagram.
    await store.insertEvent(fixture.id, fixture);
    const claimed = await store.claim(fixture.id);
    expect(claimed?.state).toBe('processing');
    expect(claimed?.processing_attempts).toBe(1);
    expect(claimed?.last_attempt_at).not.toBeNull();

    const before = await store.getEvent(fixture.id);
    expect(before?.state).toBe('processing');

    // Time passes past the lease window.
    advance(LEASE_MS + 100);

    // Stripe retries the same event id. The handler's claim sees state=
    // 'processing' with an expired lease -> reclaims (attempts=2).
    const res = await fixedHandleWebhook(
      makeReq(fixture),
      makeDeps(store, sideEffects, now),
    );
    expect(res.status).toBe(200);

    const row = await store.getEvent(fixture.id);
    expect(row?.state).toBe('processed');
    expect(row?.processing_attempts).toBe(2); // reclaimed exactly once
    expect(row?.processed_at).not.toBeNull();

    // Side effects applied exactly once total (the crashed attempt staged but
    // never committed, so the reclaim commits cleanly).
    expect(store.subscriptionsUpserted).toBe(1);
    expect(store.committedSubscriptions.has(fixture.id)).toBe(true);
  });

  it('6. attempts cap: after N failed attempts, claim refuses and returns 500', async () => {
    // A side effect that always throws. Each delivery claims, fails, and marks
    // state='failed'. The next delivery reclaims from 'failed' (no lease check).
    const failing: SideEffects = {
      applySubscription: async () => {
        throw new Error('downstream is down');
      },
    };

    // MAX_ATTEMPTS (5) attempts that each fail.
    for (let i = 0; i < MAX_ATTEMPTS; i++) {
      const res = await fixedHandleWebhook(
        makeReq(fixture),
        makeDeps(store, failing, now),
      );
      expect(res.status).toBe(500);
      const row = await store.getEvent(fixture.id);
      expect(row?.state).toBe('failed');
      expect(row?.processing_attempts).toBe(i + 1);
    }

    // 6th delivery: attempts already at the cap -> claim refuses -> 500, and
    // attempts does NOT grow past the cap. Hand off to reconciliation backfill.
    const res6 = await fixedHandleWebhook(
      makeReq(fixture),
      makeDeps(store, failing, now),
    );
    expect(res6.status).toBe(500);

    const row = await store.getEvent(fixture.id);
    expect(row?.processing_attempts).toBe(MAX_ATTEMPTS);
    expect(row?.state).toBe('failed'); // never moved to processed

    // No subscription was ever committed.
    expect(store.subscriptionsUpserted).toBe(0);
    expect(store.committedSubscriptions.has(fixture.id)).toBe(false);
  });

  it('7. signature verification rejects a bad signature (INC-006)', async () => {
    // Exercise the real HMAC path with a wrong secret. signBody produces a
    // valid header for a DIFFERENT secret, so verifySignature must reject it.
    const rawBody = Buffer.from(JSON.stringify(fixture));
    const goodSig = signBody(rawBody, 'whsec_correct', 1700000000);
    const req = {
      rawBody,
      headers: { 'stripe-signature': goodSig },
    };
    const deps: WebhookDeps = {
      store,
      sideEffects,
      now,
      leaseMs: LEASE_MS,
      maxAttempts: MAX_ATTEMPTS,
      secret: 'whsec_different', // mismatched secret
    };
    const res = await fixedHandleWebhook(req, deps);
    expect(res.status).toBe(400);
    expect(store.subscriptionsUpserted).toBe(0);

    // And a valid signature with the matching secret succeeds.
    const goodSig2 = signBody(rawBody, 'whsec_correct', 1700000000);
    const req2 = { rawBody, headers: { 'stripe-signature': goodSig2 } };
    const deps2: WebhookDeps = {
      store,
      sideEffects,
      now,
      leaseMs: LEASE_MS,
      maxAttempts: MAX_ATTEMPTS,
      secret: 'whsec_correct',
    };
    const res2 = await fixedHandleWebhook(req2, deps2);
    expect(res2.status).toBe(200);
    expect(store.subscriptionsUpserted).toBe(1);
  });
});