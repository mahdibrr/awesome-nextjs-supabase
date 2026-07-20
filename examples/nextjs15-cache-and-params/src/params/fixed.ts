import type { PageParams } from './types';

// INC-020 FIX: await the Promise before destructuring. This matches the
// real Next.js 15 contract for `params` in `app/[id]/page.tsx`.
export async function getPostIdFixed(params: PageParams): Promise<string> {
  const { id } = await params;
  return id;
}