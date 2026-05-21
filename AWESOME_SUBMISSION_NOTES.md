# Awesome Submission Notes

Notes for evaluating this repository for the awesome-list ecosystem.

## Differentiator

This repository is not only a general Next.js and Supabase resource list. Its main differentiator is the Production Incident Index: a symptom-first reference for debugging real production failures.

The index maps common incidents to likely causes and fixes:

```md
Symptom -> Root Cause -> Fix
```

Covered incidents include Supabase Auth session loss, RLS empty results, middleware redirect loops, stale App Router data, Stripe webhook failures, deployment environment mismatches, database policy issues, and Realtime authorization problems.

## Production-Incident Focus

Most existing resources explain concepts or provide starter examples. This repository adds a troubleshooting layer for developers who have already built something and need to operate it in production.

Examples of production-focused coverage:

- Supabase returns empty array.
- Next.js auth session lost after refresh.
- RLS silently fails.
- Middleware redirect loop.
- Stripe checkout succeeds but subscription state does not update.
- Realtime works for admins but not normal users.

## Ecosystem Diversity

The resource mix intentionally avoids single-domain dominance. It includes:

- Official Supabase documentation.
- Official Next.js documentation.
- Vercel guides and examples.
- Stripe documentation and samples.
- PostgreSQL references.
- Maintained GitHub repositories.
- shadcn/ui, create-t3-app, Drizzle ORM, Prisma, Playwright, Sentry, PostHog, LogRocket, and other production tools.
- Selected engineering articles from respected sources.

The list is intended to be ecosystem-first rather than a personal blog directory.

## Value Beyond Existing Awesome Repos

This repository adds value by combining:

- Curated official references.
- Production-grade open-source examples.
- SaaS and billing resources.
- RLS and Auth debugging guidance.
- Testing, monitoring, and deployment tooling.
- A dedicated incident index for real production symptoms.

It is especially useful for developers building SaaS applications with Next.js, Supabase, PostgreSQL, RLS, Stripe, App Router, and Vercel.

## Curation Standards

Resources are chosen when they are:

- Relevant to real Next.js and Supabase production work.
- Official, maintained, widely used, or written by credible engineering sources.
- Specific enough to help solve a problem or explain a tradeoff.
- Neutral in description.
- Useful without requiring a paid or gated resource.

Resources are avoided when they are:

- Generic listicles.
- Duplicate entries.
- Thin or mostly promotional.
- Unmaintained without warning.
- Not clearly relevant to this stack.

## Submission Readiness

Current readiness signals:

- Awesome badge is on the H1 line.
- `awesome-lint README.md` passes.
- README has no duplicate links.
- README has no duplicate headings.
- Internal Markdown links are valid.
- External links were checked during launch preparation.
- Contribution guidelines are present.
- Issue and pull request templates are present.
- Changelog is present.
- Repository topics include `awesome` and `awesome-list`.

Manual items to verify before opening a submission pull request:

- Confirm GitHub Discussions status.
- Confirm social preview image in repository settings.
- Re-run awesome-lint and link checks immediately before submission.
