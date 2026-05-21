# Community Guide

This repository improves when developers add real production experience back into it.

The most useful contributions are specific: a symptom, a root cause, a fix, a maintained resource, or a tool that helps someone ship a safer Next.js + Supabase app.

## How To Contribute

Good first contributions:

- Fix a broken or outdated link.
- Add an official doc that is missing from a section.
- Improve a resource description so it is shorter and more precise.
- Add a production incident with a clear symptom, root cause, and verification step.
- Suggest a maintained open-source starter or example.
- Add a tool used for testing, monitoring, deployment, migrations, or debugging.

Use a pull request for direct edits. Use an issue when you want feedback before editing.

## How To Suggest Incidents

Production incidents should be symptom-first.

Use this format:

```md
Symptom:

Root cause:

Fix:

Verification:

Reference:
```

Strong incident examples:

- Supabase returns an empty array because RLS blocks the authenticated role.
- Next.js Auth state works in the browser but fails in Server Components.
- Middleware redirects `/auth/callback` before the session is created.
- Stripe sends duplicate webhook events and creates duplicate subscription rows.
- Realtime works for admin users but not normal users because RLS blocks row visibility.

## How To Report Outdated Resources

Open an issue with:

- The resource title.
- The current URL.
- What is outdated or broken.
- A replacement link, if you know one.
- Whether the old resource should be removed, replaced, or marked as legacy.

Outdated resources include:

- Deprecated Supabase Auth helpers.
- Old Next.js Pages Router examples presented as App Router guidance.
- Unmaintained starter kits.
- Broken links or docs that moved.
- Advice that conflicts with current official docs.

## How To Propose New Tooling

Tool suggestions should explain the production workflow they improve.

Use this format:

```md
Tool:

URL:

Category:

Production use case:

Why it belongs:
```

Useful tool categories:

- Testing and browser automation.
- Error monitoring and tracing.
- Runtime logs and synthetic checks.
- Database migrations and type generation.
- Stripe webhook testing.
- Local development and environment validation.

## Help Wanted

The highest-value contribution areas right now:

- RLS incidents: empty results, blocked writes, slow policies, team membership policies.
- Deployment failures: Vercel env vars, callback URLs, Edge/runtime mismatches, build errors.
- SaaS starter kits: maintained examples with Auth, RLS, billing, and dashboard structure.
- Monitoring tools: Sentry, Checkly, PostHog, LogRocket, Vercel logs, uptime checks.
- Auth edge cases: SSR cookies, OAuth callbacks, magic links, preview deployments, middleware loops.
- Stripe billing: webhook idempotency, customer portal, subscription state sync, test/live mode mistakes.
- Realtime behavior: channel cleanup, authorization, duplicate optimistic messages, presence leaks.

## Collaboration Guidelines

- Prefer official docs when they explain the behavior clearly.
- Prefer maintained open-source projects over abandoned examples.
- Keep descriptions neutral and short.
- Avoid duplicate links.
- Add practical verification steps when possible.
- Be precise about whether a resource is current, legacy, or framework-version-specific.

Small, focused contributions are welcome. A one-line fix that prevents confusion is useful.
