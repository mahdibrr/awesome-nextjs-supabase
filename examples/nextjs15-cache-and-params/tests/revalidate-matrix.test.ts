import { describe, it, expect } from 'vitest';
import { revalidateFor } from '../src/revalidate/matrix';
import { revalidateBroken } from '../src/revalidate/broken';
import { revalidateFixed } from '../src/revalidate/fixed';
import type { RevalidateCall } from '../src/revalidate/types';

function asSet(calls: RevalidateCall[]): Set<string> {
  return new Set(calls.map((c) => `${c.kind}:${c.target}`));
}

describe('INC-008 / INC-011: revalidate matrix', () => {
  it('update-post revalidates the matching tag AND the matching path', () => {
    const calls = revalidateFor({ type: 'update-post', id: 'p1' });
    const set = asSet(calls);
    expect(set.has('tag:post:p1')).toBe(true);
    expect(set.has('path:/posts/p1')).toBe(true);
  });

  it('BROKEN: does not contain the correct tag nor the correct path', () => {
    const calls = revalidateBroken({ type: 'update-post', id: 'p1' });
    const set = asSet(calls);
    expect(set.has('tag:post:p1')).toBe(false);
    expect(set.has('path:/posts/p1')).toBe(false);
  });

  it('FIXED delegates to the matrix (single source of truth)', () => {
    const m = { type: 'update-post', id: 'p1' } as const;
    expect(revalidateFixed(m)).toEqual(revalidateFor(m));
  });

  it('delete-post revalidates the tag, the list path, and the detail path', () => {
    const calls = revalidateFor({ type: 'delete-post', id: 'p9' });
    const set = asSet(calls);
    expect(set.has('tag:post:p9')).toBe(true);
    expect(set.has('path:/posts')).toBe(true);
    expect(set.has('path:/posts/p9')).toBe(true);
  });

  it('matrix is the reusable rule: for ANY update-post id, tag matches cached-fetch key and path matches the route', () => {
    const ids = ['abc', '123', 'post_456', 'slug-with-dashes'];
    for (const id of ids) {
      const calls = revalidateFor({ type: 'update-post', id });
      const set = asSet(calls);
      // The cached fetch in the page uses `post:${id}` as its tag;
      // the route is `/posts/${id}`. The matrix must match both.
      expect(set.has(`tag:post:${id}`)).toBe(true);
      expect(set.has(`path:/posts/${id}`)).toBe(true);
    }
  });
});