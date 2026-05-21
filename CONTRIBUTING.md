# Contributing

Thanks for helping improve Awesome Next.js Supabase Resources.

This repository is meant to stay practical, neutral, and useful for developers building real production apps with Next.js, Supabase, PostgreSQL, RLS, Stripe, App Router, and related SaaS infrastructure.

## What Belongs Here

Good additions are:

- Official documentation for core platform behavior.
- Maintained open-source examples, starter kits, and tools.
- Practical guides with working implementation details.
- Debugging playbooks for real production failures.
- Architecture resources that explain tradeoffs clearly.
- Security, RLS, Auth, deployment, CI/CD, testing, performance, AI, pgvector, and SaaS resources.

## What Does Not Belong Here

Please avoid:

- Generic listicles with no implementation value.
- Thin AI-generated filler.
- Duplicate resources that cover the same topic without adding depth.
- Resources unrelated to Next.js, Supabase, PostgreSQL, SaaS, or production engineering.
- Keyword-stuffed descriptions.
- Broken links, redirects to spam, or gated pages with no useful preview.
- Personal projects that are unmaintained or mostly promotional.

## How To Suggest A Resource

Open an issue or pull request with:

- Resource title.
- URL.
- Suggested section.
- Short reason it belongs.
- The production problem, workflow, or tradeoff it helps with.

Example:

```md
Title: Supabase Row Level Security
URL: https://supabase.com/docs/guides/database/postgres/row-level-security
Section: Database, RLS, and PostgreSQL
Why it belongs: Official reference for authorization policies.
Production value: Helps debug empty results, blocked writes, and tenant isolation bugs.
```

## How To Suggest A Production Incident

Use this format for the Production Incident Index:

```md
Symptom:
Supabase returns an empty array even though rows exist.

Root cause:
RLS is enabled, but no `select` policy matches the authenticated role.

Fix:
Add a scoped `select` policy and test as the real authenticated user.

Verification:
Run the same query with the anon/authenticated client, not the service role key.

Reference:
https://supabase.com/docs/guides/database/postgres/row-level-security
```

## Formatting Conventions

- Use one Markdown bullet per resource.
- Use this resource format in the README:

```md
- [Resource Name](https://example.com) - Short neutral description.
```

- Keep descriptions short, concrete, and neutral.
- Use `Next.js`, `Supabase`, `PostgreSQL`, `Vercel`, `RLS`, `Auth`, and `App Router` consistently.
- Prefer official docs and maintained repositories over personal articles when both cover the same point.
- Do not add duplicate links.
- Place resources in the most specific section.

## Review Criteria

Pull requests are reviewed for:

- Relevance to the repository scope.
- Practical implementation or debugging value.
- Link quality and permanence.
- Maintenance status.
- Clear title and description.
- No duplicate or low-value entries.
- Neutral, ecosystem-first wording.

Small, focused pull requests are easiest to review.
