import type { PageParams } from './types';

// INC-020 BUG: Next.js 15 made `params` a Promise<{ id }>. Reading `.id`
// synchronously off the Promise object yields `undefined` at runtime
// (a Promise has no `.id` property), and TypeScript catches the shape
// mismatch — the `@ts-expect-error` below makes that error explicit.
export async function getPostIdBroken(params: PageParams): Promise<string> {
  // @ts-expect-error - demonstrating the bug: params is Promise<{id}>, not {id}
  const id = (params as { id: string }).id;
  return id; // resolves to undefined at runtime in Next 15
}