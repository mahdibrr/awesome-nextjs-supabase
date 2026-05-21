# Dev.to Article Outline

## Title Options

- The Production Bugs the Official Docs Skip: Next.js + Supabase Incident Notes
- A Production Incident Index for Next.js + Supabase Apps
- Next.js + Supabase Bugs That Show Up After the Demo Works

## Target Reader

Developers building or shipping real apps with Next.js, Supabase, PostgreSQL, RLS, Auth, Stripe, App Router, and Vercel.

## Angle

Official docs are necessary, but production debugging often starts from a symptom rather than a concept.

The article should introduce the Production Incident Index as a symptom-first debugging layer:

```md
Symptom -> Root cause -> Fix -> Verification
```

## Outline

### 1. The demo works. Production does not.

Open with the pain:

- Auth looks fine locally but fails after deploy.
- RLS blocks rows without throwing errors.
- Middleware redirects too aggressively.
- Stripe webhooks fail because the wrong secret is used.
- Cached data makes fresh database writes look broken.

### 2. Why official docs are not enough by themselves

Be careful and respectful:

- Official docs explain the system.
- Production incidents usually start with symptoms.
- Developers need a fast way to map symptom to likely root cause.

### 3. What the Production Incident Index is

Explain the format:

| Symptom                                 | Root Cause                              | Fix                                |
| --------------------------------------- | --------------------------------------- | ---------------------------------- |
| Supabase returns empty array            | RLS blocks the authenticated role       | Add/test a scoped select policy    |
| Next.js auth session lost after refresh | Server client is not reading cookies    | Verify SSR Auth and cookie refresh |
| Middleware redirect loop                | Auth routes are protected by middleware | Exclude login/callback routes      |

Link:
https://github.com/mahdibrr/awesome-nextjs-supabase/blob/main/content/incidents/README.md

### 4. Five production incidents worth checking first

Cover:

1. Supabase returns empty array.
2. RLS silently fails on update.
3. Next.js auth session lost after refresh.
4. Stripe webhook works in test but fails in production.
5. App Router data stays stale after mutation.

For each:

- Symptom.
- Likely root cause.
- First verification step.

### 5. What else is in the repo

Mention:

- Learning paths.
- Starter kits.
- Open-source examples.
- Production checklists.
- Snippets.
- Debugging playbook.
- Official docs and ecosystem tools.

Repo:
https://github.com/mahdibrr/awesome-nextjs-supabase

### 6. How to contribute

Invite practical feedback:

- Add a real incident.
- Suggest a better official reference.
- Correct misleading advice.
- Add a maintained open-source example.

### 7. Closing

Keep it humble:

> If this saves someone an afternoon of debugging Auth, RLS, middleware, or Stripe webhooks, it has done its job.

## Tags

- nextjs
- supabase
- webdev
- postgres
- saas
