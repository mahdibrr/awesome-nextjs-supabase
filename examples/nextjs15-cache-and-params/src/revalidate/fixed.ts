import { revalidateFor } from './matrix';
import type { Mutation, RevalidateCall } from './types';

// INC-008 / INC-011 FIX: delegate to the decision matrix so the Server
// Action and the tests share one source of truth.
export function revalidateFixed(m: Mutation): RevalidateCall[] {
  return revalidateFor(m);
}