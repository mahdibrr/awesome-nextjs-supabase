import type { RevalidateCall, Mutation } from './types';

// The cached fetch in the page uses tag `post:${id}` and is rendered at
// route `/posts/${id}`. This is the reusable rule both the Server Action
// and the tests rely on: revalidate the TAG the cached fetch used (so the
// data cache is busted) AND the PATH of the route that renders it (so the
// router cache is busted). Missing either → stale UI.
export function revalidateFor(m: Mutation): RevalidateCall[] {
  switch (m.type) {
    case 'update-post':
      return [
        { kind: 'tag', target: `post:${m.id}` },
        { kind: 'path', target: `/posts/${m.id}` },
      ];
    case 'delete-post':
      return [
        { kind: 'tag', target: `post:${m.id}` },
        { kind: 'path', target: `/posts` },
        { kind: 'path', target: `/posts/${m.id}` },
      ];
    default:
      throw new Error(`unknown mutation: ${(m as Mutation).type}`);
  }
}