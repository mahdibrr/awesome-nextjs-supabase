import type { Mutation, RevalidateCall } from './types';

// INC-008 / INC-011 BUG: revalidates the WRONG path (the admin route, not
// the public route) and never touches the TAG the cached fetch used. The
// public `/posts/[id]` route cache and the data cache both stay stale.
export function revalidateBroken(m: Mutation): RevalidateCall[] {
  return [{ kind: 'path', target: '/admin/posts' }]; // wrong path + no tag → stale
}