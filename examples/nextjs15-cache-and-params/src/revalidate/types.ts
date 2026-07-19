export type RevalidateCall = { kind: 'path' | 'tag'; target: string };

export type Mutation =
  | { type: 'update-post'; id: string }
  | { type: 'delete-post'; id: string };