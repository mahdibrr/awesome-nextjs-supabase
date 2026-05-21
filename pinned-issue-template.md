# Suggest a Resource or Production Incident

Use this pinned issue to suggest useful resources, missing production incidents, or corrections.

## What To Suggest

Good suggestions usually include one of these:

- A real production symptom.
- A likely root cause.
- A fix or verification step.
- An official doc, maintained GitHub repo, or high-quality engineering writeup.
- A production checklist item that would have prevented a real bug.

## Production Incident Format

```md
Symptom:

Root cause:

Fix:

Verification step:

Reference:
```

Example:

```md
Symptom:
Supabase returns an empty array even though rows exist.

Root cause:
RLS is enabled, but there is no `select` policy for the authenticated role.

Fix:
Add a scoped `select` policy and test as a real authenticated user.

Verification step:
Run the same query with the anon/authenticated client, not the service role key.

Reference:
https://supabase.com/docs/guides/database/postgres/row-level-security
```

## Resource Format

```md
Title:

URL:

Section:

Why it belongs:

What production problem it helps solve:
```

## Please Avoid

- Generic listicles.
- Duplicate resources.
- Keyword-stuffed descriptions.
- Unmaintained projects with no clear warning.
- Paid-only resources with no useful public preview.
- Anything unrelated to Next.js, Supabase, PostgreSQL, RLS, Auth, Stripe, App Router, SaaS, deployment, testing, monitoring, or production debugging.
