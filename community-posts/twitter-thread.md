# Twitter/X Thread

## Thread

1. The demo works.

Then production breaks.

I made a Next.js + Supabase resource hub for the bugs that usually show up after deployment: Auth, RLS, middleware, caching, Stripe, Realtime, env vars, and database policies.

https://github.com/mahdibrr/awesome-nextjs-supabase

2. The main piece is the Production Incident Index.

It is symptom-first:

```md
Symptom -> Root cause -> Fix
```

Useful when you know what broke, but not where to start.

3. Example:

"Supabase returns empty array"

Likely cause:
RLS is enabled, but there is no matching `select` policy for the authenticated role.

First check:
Test as the real user, not with the service role key.

4. Example:

"Next.js auth session lost after refresh"

Likely cause:
The browser client has a session, but the server client is not reading or refreshing cookies.

First check:
Verify server-side Supabase Auth and cookies on a protected route.

5. Example:

"middleware redirect loop"

Likely cause:
Middleware protects the login or callback route, so the session never finishes being created.

First check:
Exclude auth callback and login routes from protected matchers.

6. Example:

"Stripe checkout worked, but user is still on free plan"

Likely cause:
Webhook sync failed or was not idempotent.

First check:
Verify signing secret, event handling, and subscription table updates.

7. The repo also includes:

- Production checklists
- Starter kits
- Open-source examples
- Debugging playbooks
- Snippets
- Official docs
- Monitoring/testing tools

8. This is not meant to replace official docs.

It is the war-room layer next to them: quick symptoms, likely root causes, and verification steps.

Production Incident Index:
https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

9. If you have shipped with Next.js + Supabase, I would love missing incidents.

What bug should be added next?

Auth, RLS, middleware, caching, Stripe, Realtime, deployment, migrations, or Edge runtime?
