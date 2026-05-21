# LinkedIn Post

Most Next.js + Supabase tutorials stop when the demo works.

Production fails later.

The bugs are usually not glamorous:

- Auth works locally, then sessions disappear after refresh.
- Supabase returns an empty array because RLS is blocking the real user.
- Middleware creates a redirect loop.
- App Router data stays stale after a mutation.
- Stripe checkout succeeds, but subscription state never updates.
- Realtime works for admins but not for normal users.

I put together a production-focused resource hub for this stack:

https://github.com/mahdibrr/awesome-nextjs-supabase

The main differentiator is the Production Incident Index:

https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

It maps production symptoms to likely root causes, fixes, and verification steps.

The repo also includes official docs, starter kits, open-source examples, production checklists, snippets, debugging playbooks, testing resources, monitoring tools, and SaaS architecture references.

The goal is simple:

Make the repository useful even if you never leave GitHub.

If you have shipped with Next.js + Supabase, I would love feedback:

- What incident is missing?
- Which resource should be added?
- Which advice needs correction?

Trying to keep it practical, neutral, and community-curated.
