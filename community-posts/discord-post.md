# Discord Post

## Short Version

I put together a production-focused Next.js + Supabase resource hub:

https://github.com/mahdibrr/awesome-nextjs-supabase

The main useful part is the Production Incident Index: symptoms, likely root causes, fixes, and verification steps for Auth, RLS, middleware, caching, Stripe, deployment, database, and Realtime issues.

Incident index:
https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

Examples covered:

- Supabase returns empty array
- Next.js auth session lost after refresh
- RLS silently fails
- Middleware redirect loop
- Stripe webhook works in test but fails in production

Would love suggestions for missing incidents or better references.

## Longer Version

I made a Next.js + Supabase awesome list aimed at the bugs that show up after the tutorial works.

It is not meant to be another generic bookmark dump. The main piece is a Production Incident Index that maps:

```md
Symptom -> Root cause -> Fix
```

The repo also has learning paths, starter kits, open-source examples, production checklists, snippets, and debugging playbooks.

Repo:
https://github.com/mahdibrr/awesome-nextjs-supabase

Production Incident Index:
https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

If you have shipped something with Next.js + Supabase, I am especially looking for missing production incidents: Auth, RLS, middleware, deployment, caching, Stripe, Realtime, Edge runtime, or migrations.

## Follow-Up Prompt

What production bug should be added next?

- Auth/session
- RLS/database policies
- Middleware redirects
- Stripe billing
- Realtime
- Deployment/env vars
- Caching/stale data
