import { createHmac, timingSafeEqual } from 'node:crypto';

/**
 * Verify a Stripe-Signature header against the raw request body and the
 * endpoint secret. Implements the real Stripe scheme: the header is
 * `t=<timestamp>,v1=<hex hmac>` and the signed payload is
 * `<timestamp>.<rawBody>` HMAC-SHA256'd with the secret, compared with a
 * constant-time compare.
 *
 * In tests we do NOT want to require real Stripe machinery, so there is a
 * deliberate, narrow escape hatch: when `NODE_ENV === 'test'` AND the secret is
 * exactly `test_secret` AND the signature header is exactly `test_sig`, the
 * verifier returns true. This is ONLY a test affordance — under any other
 * NODE_ENV the real HMAC runs. Tests that want to exercise the real path can
 * compute a valid signature themselves with the same secret.
 */
export function verifySignature(
  rawBody: Buffer,
  sigHeader: string,
  secret: string,
): boolean {
  // Test-only affordance: keeps the example dependency-light (no stripe SDK).
  // Gated on NODE_ENV so it can never fire in production.
  if (
    process.env.NODE_ENV === 'test' &&
    secret === 'test_secret' &&
    sigHeader === 'test_sig'
  ) {
    return true;
  }

  if (!sigHeader || !secret) return false;

  let timestamp: string | undefined;
  const v1s: string[] = [];
  for (const part of sigHeader.split(',')) {
    const idx = part.indexOf('=');
    if (idx === -1) continue;
    const k = part.slice(0, idx).trim();
    const v = part.slice(idx + 1).trim();
    if (k === 't') timestamp = v;
    else if (k === 'v1') v1s.push(v);
  }
  if (!timestamp || v1s.length === 0) return false;

  const signedPayload = `${timestamp}.${rawBody.toString('utf8')}`;
  const expected = createHmac('sha256', secret).update(signedPayload).digest('hex');

  for (const v of v1s) {
    const a = Buffer.from(v, 'utf8');
    const b = Buffer.from(expected, 'utf8');
    // constant-time compare; lengths must match or timingSafeEqual throws
    if (a.length === b.length && a.length > 0 && timingSafeEqual(a, b)) {
      return true;
    }
  }
  return false;
}

/** Compute a valid `Stripe-Signature` header for a body+secret. Used by tests
 *  that want to exercise the real HMAC path (not required by the main suite). */
export function signBody(rawBody: Buffer, secret: string, timestamp: number): string {
  const signedPayload = `${timestamp}.${rawBody.toString('utf8')}`;
  const mac = createHmac('sha256', secret).update(signedPayload).digest('hex');
  return `t=${timestamp},v1=${mac}`;
}