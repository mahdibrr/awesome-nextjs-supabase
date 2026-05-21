# Reddit Post

## Title Options

- I made a Production Incident Index for Next.js + Supabase bugs
- Common Next.js + Supabase production failures and how to debug them
- A symptom-first reference for Supabase Auth, RLS, middleware, Stripe, and deployment issues

## Post

I kept running into the same kind of Next.js + Supabase problems after apps moved past the tutorial stage:

- Supabase returns an empty array even though rows exist.
- Auth works locally, then the session disappears after refresh.
- Middleware creates a redirect loop between login and dashboard.
- Stripe checkout succeeds, but the app still shows the free plan.
- Realtime works for admins but not normal users.
- App Router data stays stale after a mutation.

So I put together a production-focused awesome list with the main differentiator being a Production Incident Index:

Repository:
https://github.com/mahdibrr/awesome-nextjs-supabase

Incident index:
https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

The goal is not to replace official docs. It is more of a war-room reference for the bugs that happen after the demo works: symptom, likely root cause, fix, and verification step.

It also includes official docs, starter kits, open-source examples, production checklists, snippets, debugging notes, testing/monitoring resources, and SaaS architecture references.

I would appreciate feedback from people who have shipped with this stack:

- What production incident is missing?
- Which resources should be added or removed?
- Are any descriptions misleading?

Trying to keep it practical and community-curated, not a link farm.

## First Comment

If you only check one part, the Production Incident Index is the useful bit:

https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

It covers Auth, RLS, middleware, deployment, caching, Stripe, database, and Realtime failures.
