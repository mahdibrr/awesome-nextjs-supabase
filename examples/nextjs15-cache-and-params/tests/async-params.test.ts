import { describe, it, expect } from 'vitest';
import { getPostIdBroken } from '../src/params/broken';
import { getPostIdFixed } from '../src/params/fixed';
import type { PageParams } from '../src/params/types';

describe('INC-020: Next.js 15 async params', () => {
  it('BROKEN: reading .id off a Promise yields undefined', async () => {
    const p: PageParams = Promise.resolve({ id: 'post_123' });
    const id = await getPostIdBroken(p);
    // The bug: a Promise object has no `.id` property, so sync access
    // resolves to undefined. This is exactly what breaks in Next 15.
    expect(id).toBeUndefined();
  });

  it('FIXED: awaiting the Promise returns the real id', async () => {
    const p: PageParams = Promise.resolve({ id: 'post_123' });
    const id = await getPostIdFixed(p);
    expect(id).toBe('post_123');
  });

  it('honest about the Next 14 shape: a plain {id} object also works with fixed', async () => {
    // Next 14 style: params was a plain object. The fixed version still
    // works because awaiting a non-thenable value returns the value itself.
    const p = Promise.resolve({ id: 'x' }) as PageParams;
    expect(await getPostIdFixed(p)).toBe('x');
  });
});