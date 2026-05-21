# Resource Requests

Use this file as a backlog of useful resource requests for the community.

If you know a strong resource for one of these areas, open an issue or pull request.

## Requested Resources

| Area                | Looking For                                                                            | Notes                                                             |
| ------------------- | -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| RLS policies        | Practical examples for team membership, roles, and ownership.                          | Prefer official docs, maintained examples, or clear SQL writeups. |
| Supabase Auth       | SSR cookie handling, OAuth callbacks, magic links, and preview deployments.            | App Router examples are preferred.                                |
| Deployment          | Vercel env var mistakes, Edge/runtime mismatches, and build failures.                  | Include verification steps when possible.                         |
| Stripe billing      | Webhook idempotency, subscription sync, customer portal, test/live mode issues.        | Official Stripe docs and maintained samples are ideal.            |
| SaaS starter kits   | Maintained Next.js + Supabase starters with Auth, RLS, Stripe, and dashboard patterns. | Avoid abandoned boilerplates.                                     |
| Monitoring tools    | Sentry, Checkly, PostHog, LogRocket, Vercel logs, uptime checks.                       | Explain the production failure each tool catches.                 |
| Database migrations | Supabase CLI, Drizzle, Prisma, generated types, rollback patterns.                     | Prefer production-safe workflows.                                 |
| Realtime            | Authorization, presence cleanup, duplicate optimistic messages, channel lifecycle.     | Add symptoms and fixes when possible.                             |
| Testing             | Playwright flows for Auth, billing, RLS, and protected routes.                         | Concrete examples are best.                                       |
| Edge Functions      | Supabase Edge Functions, webhooks, secrets, scheduled jobs, runtime gotchas.           | Current docs only.                                                |

## Request Format

```md
Area:

Resource type:
Official docs / GitHub repo / article / tool / starter kit

Why it is needed:

Suggested URL:

Production problem it helps solve:
```

## Quality Bar

Requested resources should be:

- Relevant to Next.js, Supabase, PostgreSQL, RLS, Auth, Stripe, App Router, SaaS, testing, monitoring, or deployment.
- Current enough to be useful for production work.
- Clear about framework versions or legacy patterns.
- Useful without requiring private access.
- More practical than generic.

## Already Strong Areas

These areas already have a good baseline, but high-quality additions are still welcome:

- Official Supabase docs.
- Official Next.js docs.
- Stripe official docs and samples.
- Vercel deployment references.
- Production Incident Index.

## Maintainer Notes

When reviewing requested resources:

- Prefer official docs over third-party summaries when both solve the same need.
- Prefer maintained repositories over archived examples.
- Keep descriptions short.
- Reject resources that are mostly promotional.
- Avoid adding several links that all explain the same beginner concept.
