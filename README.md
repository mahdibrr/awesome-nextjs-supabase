# Awesome Supabase Resources [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

[![Link Check](https://github.com/mahdibrr/awesome-nextjs-supabase/actions/workflows/link-check.yml/badge.svg)](https://github.com/mahdibrr/awesome-nextjs-supabase/actions/workflows/link-check.yml)
[![Contributors](https://img.shields.io/github/contributors/mahdibrr/awesome-nextjs-supabase)](https://github.com/mahdibrr/awesome-nextjs-supabase/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/mahdibrr/awesome-nextjs-supabase)](https://github.com/mahdibrr/awesome-nextjs-supabase/commits/main)

The production bugs the official docs skip.

A practical, production-first reference for developers building with Next.js, Supabase, PostgreSQL, RLS, Auth, Stripe, App Router, Server Actions, TypeScript, and Vercel.

Use it when the demo works, the deployment does not, and you need the fastest path from symptom to root cause.

## Contents

- [Why This Exists](#why-this-exists)
- [What This Repo Covers](#what-this-repo-covers)
- [Selection Criteria](#selection-criteria)
- [How Resources Are Chosen](#how-resources-are-chosen)
- [Start Here](#start-here)
- [Most Useful Sections](#most-useful-sections)
- [Frequently Searched Problems](#frequently-searched-problems)
- [Production Failure Categories](#production-failure-categories)
- [Quick Production Checks](#quick-production-checks)
- [Copy-Paste Fixes](#copy-paste-fixes)
- [Top Production Mistakes](#top-production-mistakes)
- [Quick Triage](#quick-triage)
- [Recently Added](#recently-added)
- [Recently Updated](#recently-updated)
- [Official References](#official-references)
- [Resources](#resources)
- [Tools](#tools)
- [Community](#community)

## Why This Exists

Most tutorials stop when sign-in works locally.

Real products fail later:

- Auth sessions disappear after refresh.
- RLS returns empty arrays without errors.
- Middleware creates redirect loops.
- Static caching leaks stale or user-specific data.
- Stripe webhooks pass in test mode and fail in production.
- Preview deployments use the wrong callback URLs or environment variables.

This repository is a war-room reference for those moments. It favors official docs, real open-source examples, production checklists, debugging playbooks, and short notes that help you verify the fix.

## What This Repo Covers

- Next.js App Router, Server Components, Server Actions, caching, and deployment behavior.
- Supabase Auth, SSR sessions, RLS, PostgreSQL, Realtime, Storage, Edge Functions, and local development.
- Next.js Supabase SaaS architecture, multi-tenant data models, Stripe Supabase SaaS billing sync, and production launch checks.
- Debugging workflows for auth, middleware, hydration, database policies, webhooks, stale data, and deployment failures.
- Testing, monitoring, observability, migrations, type generation, and production tooling.

## Selection Criteria

Resources should be:

- Directly relevant to Next.js, Supabase, PostgreSQL, RLS, Auth, Stripe, App Router, SaaS, deployment, testing, monitoring, or production debugging.
- Useful to developers building or operating real applications.
- Maintained, official, widely used, or written by a credible engineering source.
- Specific enough to solve a problem or explain an important tradeoff.
- Described neutrally, without hype or keyword stuffing.

Resources are avoided when they are generic, duplicate an existing entry without adding depth, are mostly promotional, are outdated without warning, or have no meaningful public content.

## How Resources Are Chosen

The list prioritizes:

1. Official documentation for core platform behavior.
2. Maintained open-source examples and starter kits.
3. Production-grade tools used for testing, monitoring, debugging, billing, and deployment.
4. Engineering articles that explain real architecture, failure modes, or tradeoffs.
5. Focused internal notes only when they fill a practical gap not covered by official docs.

## Start Here

| Need                                                   | Go To                                                            |
| ------------------------------------------------------ | ---------------------------------------------------------------- |
| Find the likely root cause from a symptom              | [Production Incident Index](content/incidents/README.md)         |
| Learn the stack in order                               | [Learning Paths](content/learning-paths/README.md)               |
| Start from a real app shape                            | [Starter Kits](content/starter-kits/README.md)                   |
| Study production-oriented repositories                 | [Open Source Examples](content/open-source-examples/README.md)   |
| Ship with fewer missed checks                          | [Production Checklists](content/production-checklists/README.md) |
| Copy small implementation patterns                     | [Snippets](content/snippets/README.md)                           |
| Debug auth, RLS, hydration, API, and deployment issues | [Debugging Playbook](content/debugging-playbook/README.md)       |

## Most Useful Sections

| Section                   | Why It Is Worth Bookmarking                                                                                                        |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Production Incident Index | Symptom-first table for common failures like "Supabase returns empty array", "RLS silently fails", and "middleware redirect loop". |
| Auth and Security         | Cookie-based SSR Auth, OAuth callbacks, middleware protection, RLS, and production hardening.                                      |
| Database and RLS          | Policy design, slow policy debugging, PostgreSQL indexes, migrations, and type generation.                                         |
| Stripe and Billing        | Webhook signatures, idempotency, subscription state sync, and customer portal flows.                                               |
| Testing and Monitoring    | Playwright, Sentry, runtime logs, synthetic checks, analytics, and production verification loops.                                  |

## Frequently Searched Problems

| Search Intent                | Start Here                     | What To Check First                                                 |
| ---------------------------- | ------------------------------ | ------------------------------------------------------------------- |
| Supabase RLS guide           | Database, RLS, and PostgreSQL  | Policy operation, `auth.uid()`, `using`, `with check`, and indexes. |
| RLS policy debugging         | Production Incident Index      | Test with anon/authenticated users instead of `service_role`.       |
| Supabase empty array fix     | Quick Production Checks        | RLS is enabled but no `select` policy matches the user.             |
| Supabase auth App Router     | Auth and Security              | Server-side cookies, callback URLs, middleware exclusions.          |
| Supabase SSR auth            | Official References            | Server client reads refreshed cookies on protected SSR routes.      |
| Next.js middleware auth      | Production Failure Categories  | `/login` and `/auth/callback` are excluded from protected matchers. |
| Next.js production debugging | Quick Triage                   | Logs, cookies, redirects, env vars, cache behavior, and RLS role.   |
| Next.js Supabase SaaS        | SaaS Architecture and Starters | Auth, RLS, billing, tenant isolation, and deployment checks.        |
| Stripe Supabase SaaS         | Stripe and Billing             | Webhook signing, idempotency, customer IDs, subscription sync.      |

## Production Failure Categories

| Category   | Common Symptom                                                           | First Check                                                            |
| ---------- | ------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| Auth       | Supabase auth App Router session works locally, then fails after deploy. | Check callback allowlists, cookies, and server-side `auth.getUser()`.  |
| RLS        | Supabase returns an empty array for rows that exist.                     | Test as the real authenticated role, not the service role.             |
| Middleware | Next.js middleware auth creates a login/dashboard redirect loop.         | Exclude auth callback/login routes from protected matchers.            |
| Caching    | Dashboard shows stale or wrong user data.                                | Mark user-specific routes dynamic and revalidate mutation paths.       |
| Billing    | Checkout succeeds but the app still shows free plan.                     | Verify webhook signature, idempotency, and subscription table updates. |
| Deployment | Works locally, fails on Vercel.                                          | Compare production, preview, and local environment variables.          |
| Realtime   | Chat or presence works for admins only.                                  | Check Realtime enablement, channel cleanup, and RLS visibility.        |

## Quick Production Checks

Run these before blaming the framework.

| Check                     | Command Or Probe                                            | Passes When                                                            |
| ------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------- |
| Verify RLS                | Query with the anon/authenticated client, not service role. | Existing rows are visible only to the intended user.                   |
| Verify Supabase SSR auth  | Refresh a protected SSR page after login.                   | Server code still sees `auth.getUser()`.                               |
| Verify SSR cookies        | Inspect `Set-Cookie` and request cookies in Network tab.    | Auth cookies are present on protected requests.                        |
| Verify Stripe webhooks    | Replay an event with Stripe CLI or dashboard logs.          | Signature verifies and the subscription row updates once.              |
| Verify middleware         | `curl -I /login`, `/auth/callback`, and `/dashboard`.       | Login/callback are not trapped in a redirect loop.                     |
| Verify cache invalidation | Mutate data, refresh, then check the same route.            | Fresh data appears after `revalidatePath` or `revalidateTag`.          |
| Verify env vars           | Compare local, preview, and production settings.            | URL, anon key, webhook secret, and callback URL match the environment. |

## Copy-Paste Fixes

Use these as starting points, then narrow them to your app.

```sql
-- RLS: user-owned rows.
create policy "Users can read own rows"
on public.todos
for select
to authenticated
using (user_id = auth.uid());
```

```sql
-- RLS: team-owned rows through membership.
create policy "Members can read team rows"
on public.projects
for select
to authenticated
using (
  exists (
    select 1
    from public.memberships m
    where m.team_id = projects.team_id
      and m.user_id = auth.uid()
  )
);
```

```ts
// Auth guard for route handlers and Server Components.
const {
  data: { user },
  error,
} = await supabase.auth.getUser();

if (error || !user) {
  return new Response("Unauthorized", { status: 401 });
}
```

```ts
// App Router cache fix after a Server Action mutation.
import { revalidatePath } from "next/cache";

await updateProject(input);
revalidatePath("/dashboard/projects");
```

```ts
// Minimal env validation at startup.
const required = [
  "NEXT_PUBLIC_SUPABASE_URL",
  "NEXT_PUBLIC_SUPABASE_ANON_KEY",
  "STRIPE_WEBHOOK_SECRET",
];

for (const key of required) {
  if (!process.env[key]) throw new Error(`Missing env var: ${key}`);
}
```

```ts
// Middleware matcher: avoid protecting auth callback/static assets.
export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|login|auth/callback).*)",
  ],
};
```

## Top Production Mistakes

- Trusting `service_role` in client code instead of testing with anon/authenticated users.
- Enabling RLS without adding `select`, `insert`, `update`, and `delete` policies for real flows.
- Writing an `update` policy with `using` but forgetting `with check`.
- Forgetting `revalidatePath` or `revalidateTag` after Server Actions.
- Protecting `/login` or `/auth/callback` in middleware and creating a redirect loop.
- Setting Supabase Site URL to localhost while production uses a real domain.
- Using the test Stripe webhook secret in production.
- Not storing processed Stripe event IDs, causing duplicate billing state changes.
- Reading browser-only values during server render and causing hydration mismatch.
- Subscribing to Realtime channels without removing them on cleanup.

## Quick Triage

Run these Next.js production debugging checks before rewriting working code.

```ts
// Server-side auth must be the source of truth for protected data.
const {
  data: { user },
  error,
} = await supabase.auth.getUser();

if (error || !user) {
  // Redirect, return 401, or show a stable logged-out state.
}
```

```ts
// User-specific App Router data should not be accidentally static.
export const dynamic = "force-dynamic";
```

```sql
-- RLS debugging: verify the role and the exact row visibility condition.
select auth.uid();
select * from your_table limit 5;
```

```bash
# Redirect and cookie debugging for middleware/callback loops.
curl -I https://your-domain.com/auth/callback
curl -I https://your-domain.com/dashboard
```

Quick fixes that solve a surprising number of production incidents:

- Add the exact production and preview callback URLs to Supabase Auth settings.
- Never expose the service role key to browser code.
- Add indexes for columns used inside RLS policy predicates.
- Use `revalidatePath` or `revalidateTag` after Server Actions that change visible data.
- Store processed Stripe event IDs so webhook retries stay idempotent.
- Remove Supabase Realtime channels on component cleanup.

## Recently Added

- Production Incident Index with 20+ symptom-to-root-cause debugging entries.
- Cleaner ecosystem balance across official docs, GitHub examples, and production tools.
- Local development, migration, type generation, testing, and monitoring references.
- Link checking, contribution templates, issue templates, changelog, and maintainer signals.

## Recently Updated

- Added practical production checks, copy-paste fixes, and top production mistakes directly in the README.
- Added awesome-list submission notes and clearer curation criteria.
- Added launch materials for Reddit, Discord, LinkedIn, Twitter/X, and Dev.to.
- Added contributor onboarding docs for good first issues, resource requests, and community participation.

## Official References

- [Next.js Documentation](https://nextjs.org/docs) - Framework reference for App Router, rendering, caching, data fetching, and deployment.
- [Next.js App Router](https://nextjs.org/docs/app) - Layouts, routing, loading UI, Server Components, and route handlers.
- [Next.js Server Actions](https://nextjs.org/docs/app/getting-started/mutating-data) - Official mutation and form handling reference.
- [Supabase Documentation](https://supabase.com/docs) - Auth, PostgreSQL, Storage, Realtime, Edge Functions, and local development.
- [Supabase Server-Side Auth](https://supabase.com/docs/guides/auth/server-side) - Cookie-based Auth for SSR and server-rendered apps.
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) - Production authorization with PostgreSQL policies.
- [Supabase Going Into Production](https://supabase.com/docs/guides/deployment/going-into-prod) - Platform readiness checks before launch.
- [Stripe Billing](https://docs.stripe.com/billing) - Subscriptions, invoices, customers, and pricing models.
- [Vercel Next.js Deployment](https://vercel.com/docs/frameworks/nextjs) - Deployment behavior for Next.js on Vercel.
- [GitHub Actions](https://docs.github.com/en/actions) - CI/CD automation for tests, checks, and scheduled tasks.

## Resources

### Next.js and App Router

- [Making Sense of React Server Components](https://www.joshwcomeau.com/react/server-components/) - Clear mental model for React Server Components and SSR.
- [Understanding React Server Components](https://vercel.com/blog/understanding-react-server-components) - Vercel's architectural breakdown of RSC data flow.
- [Understanding App Directory Architecture in Next.js](https://www.smashingmagazine.com/2023/02/understanding-app-directory-architecture-next-js/) - Practical App Router structure and tradeoffs.
- [Lee Robinson on Next.js](https://leerob.com/) - Practical writing and examples from a long-time Next.js maintainer and Vercel educator.
- [T3 Stack](https://create.t3.gg/) - Type-safe full-stack Next.js conventions for opinionated teams.
- [Next.js App Router Complete Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide) - Routing, layouts, Server Components, and production patterns.

### Auth and Security

- [Supabase Auth Quickstart for Next.js](https://supabase.com/docs/guides/auth/quickstarts/nextjs) - Official Auth setup, middleware configuration, and protected routes.
- [Build a Full-Stack App with Next.js and Supabase](https://blog.logrocket.com/build-full-stack-app-next-js-supabase/) - LogRocket walkthrough covering Auth, RLS, and deployment basics.
- [Supabase Auth UI React](https://github.com/supabase/auth-ui) - Official Auth UI components for a fast baseline.
- [Supabase SSR Package](https://github.com/supabase/ssr) - Official helpers for cookie-based SSR sessions.
- [Supabase Auth and Middleware Session Management](https://www.iloveblogs.blog/guides/supabase-auth-complete-session-middleware-guide) - Supabase auth App Router patterns, SSR cookies, and middleware route protection.
- [Supabase Authentication and Authorization Patterns](https://www.iloveblogs.blog/guides/supabase-authentication-authorization) - Email/password Auth, magic links, OAuth, RBAC, RLS, and authorization models.
- [Next.js and Supabase Security Best Practices](https://www.iloveblogs.blog/guides/nextjs-supabase-security-best-practices) - RLS policies, secret management, API security, and Auth hardening.

### Database, RLS, and PostgreSQL

- [RLS Performance and Best Practices](https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv) - Official guide for indexing policies and avoiding slow RLS checks.
- [Supabase Security Suite](https://supabase.com/blog/hardening-supabase) - Production hardening for RLS, Column Level Security, and network restrictions.
- [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html) - Query-plan reference for slow Supabase queries.
- [Supabase Database Functions](https://supabase.com/docs/guides/database/functions) - PostgreSQL functions, security mode, and RPC patterns.
- [Supabase Connection Pooler](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler) - Pooled database access for serverless deployments.
- [Database Migration Strategies for Production Supabase Apps](https://www.iloveblogs.blog/guides/nextjs-supabase-migration-strategies) - Supabase RLS guide companion for schema versioning, rollback strategy, and production-safe migrations.
- [Database Design and Optimization for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-database-design-optimization) - Schema design, indexing, and query optimization.

### SaaS Architecture and Starters

- [SaaS Starter by Next.js](https://github.com/nextjs/saas-starter) - Official starter with Next.js, PostgreSQL, Drizzle ORM, Stripe, and shadcn/ui.
- [Vercel Subscription Payments](https://github.com/vercel/nextjs-subscription-payments) - Subscription reference app with Next.js, Supabase, and Stripe.
- [Theo Browne](https://t3.gg/) - Practical opinions on full-stack TypeScript and SaaS defaults.
- [shadcn/ui Blocks](https://ui.shadcn.com/blocks) - Dashboard and application blocks for SaaS interfaces.
- [Vercel with-supabase Example](https://github.com/vercel/next.js/tree/canary/examples/with-supabase) - Official App Router and Supabase example.
- [KolbySisk/next-supabase-stripe-starter](https://github.com/KolbySisk/next-supabase-stripe-starter) - SaaS starter with Stripe, React Email, and shadcn/ui.
- [makerkit/nextjs-saas-starter-kit-lite](https://github.com/makerkit/nextjs-saas-starter-kit-lite) - Lite open-source SaaS starter based on Next.js and Supabase.
- [antoineross/Hikari](https://github.com/antoineross/Hikari) - Open-source SaaS template using App Router, Stripe, and Supabase.
- [t3-oss/create-t3-app](https://github.com/t3-oss/create-t3-app) - Popular TypeScript-first Next.js starter.
- [shadcn Taxonomy](https://github.com/shadcn-ui/taxonomy) - Real-world app structure reference for Next.js and UI composition.
- [Complete Guide to Building SaaS with Next.js and Supabase](https://www.iloveblogs.blog/guides/building-saas-nextjs-supabase) - Next.js Supabase SaaS architecture from database design to production launch checks.

### Local Development

- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) - Local projects, database reset, migrations, seeds, and generated types.
- [Supabase Local Development](https://supabase.com/docs/guides/local-development) - Run the Supabase stack locally.
- [Next.js Environment Variables](https://nextjs.org/docs/app/guides/environment-variables) - Server-only secrets and public client variables.
- [Vercel Environment Variables](https://vercel.com/docs/projects/environment-variables) - Production, preview, and development environment scoping.
- [shadcn/ui Installation for Next.js](https://ui.shadcn.com/docs/installation/next) - Common UI baseline for dashboards and settings pages.
- [Docker Compose](https://docs.docker.com/compose/) - Local dependencies around PostgreSQL, queues, and support services.

### Migrations and Type Generation

- [Supabase Database Migrations](https://supabase.com/docs/guides/local-development/overview) - Official migration workflow for local and remote projects.
- [Generating TypeScript Types](https://supabase.com/docs/guides/api/rest/generating-types) - Generate database types from Supabase schemas.
- [Drizzle with Supabase](https://supabase.com/docs/guides/database/drizzle) - Use Drizzle ORM with a Supabase database.
- [Drizzle Migrations](https://orm.drizzle.team/docs/migrations) - Migration generation and folder workflow.
- [Prisma with Next.js](https://www.prisma.io/docs/guides/nextjs) - Prisma setup for schema, queries, and deployment.
- [Prisma Migrate](https://www.prisma.io/docs/orm/prisma-migrate) - Migration workflow for Prisma teams.

### Stripe and Billing

- [Stripe Webhooks](https://docs.stripe.com/webhooks) - Webhook signatures, retries, and event handling.
- [Stripe Launch Checklist](https://docs.stripe.com/get-started/account/checklist) - Checks before taking real payments.
- [stripe-samples/subscription-use-cases](https://github.com/stripe-samples/subscription-use-cases) - Official subscription samples.
- [stripe-samples/checkout-single-subscription](https://github.com/stripe-samples/checkout-single-subscription) - Single-subscription checkout sample.
- [Stripe Customer Portal](https://docs.stripe.com/customer-management) - Subscription management, invoices, and customer self-service.
- [Stripe Testing](https://docs.stripe.com/testing) - Test cards, clocks, and integration checks.
- [Next.js and Supabase Stripe Subscriptions Guide](https://www.iloveblogs.blog/guides/nextjs-supabase-stripe-subscriptions-guide) - Stripe Supabase SaaS webhooks, user syncing, gated content, and subscription state.

### Realtime, Performance, and AI

- [Supabase Realtime](https://supabase.com/docs/guides/realtime) - Broadcast, Presence, and PostgreSQL Changes.
- [Using Realtime with Next.js](https://supabase.com/docs/guides/realtime/realtime-with-nextjs) - Official guide for Realtime in Next.js apps.
- [Subscribing to Database Changes](https://supabase.com/docs/guides/realtime/subscribing-to-database-changes) - PostgreSQL Changes, RLS requirements, and filtering.
- [Realtime Authorization](https://supabase.com/docs/guides/realtime/authorization) - Role-based authorization for Realtime channels.
- [Vercel Data Cache for Next.js](https://vercel.com/blog/vercel-cache-api-nextjs-cache) - Production cache behavior and APIs.
- [How to Maintain a Large Next.js Application](https://www.smashingmagazine.com/2021/11/maintain-large-nextjs-application/) - Organization, performance budgets, and maintainability.
- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) - Automated performance and quality checks.
- [Next.js Caching and Revalidating](https://nextjs.org/docs/app/getting-started/caching-and-revalidating) - App Router caching and invalidation.
- [Vercel Speed Insights](https://vercel.com/docs/speed-insights) - Real user performance monitoring.
- [Supabase AI and Vectors](https://supabase.com/docs/guides/ai) - Vector search and AI workflows.
- [supabase-community/nextjs-openai-doc-search](https://github.com/supabase-community/nextjs-openai-doc-search) - Next.js, OpenAI, and Supabase document search.
- [Vercel AI Chatbot](https://github.com/vercel/chatbot) - High-quality AI chat architecture reference.

### Production Fixes and Comparisons

- [Next.js Hydration Error Guide](https://nextjs.org/docs/messages/react-hydration-error) - Official hydration mismatch guide.
- [Supabase Troubleshooting](https://supabase.com/docs/guides/troubleshooting) - Official Supabase troubleshooting entry point.
- [Chrome DevTools Network Panel](https://developer.chrome.com/docs/devtools/network/) - Debug redirects, cookies, headers, and failed requests.
- [Sentry Tracing](https://docs.sentry.io/platforms/javascript/guides/nextjs/tracing/) - Trace slow requests, route handlers, and client interactions.
- [Next.js Hydration Mismatch Error Fixes](https://www.iloveblogs.blog/post/nextjs-hydration-mismatch-fix) - App Router and React diagnostics.
- [Fix Next.js Module Not Found After Deploy](https://www.iloveblogs.blog/post/nextjs-build-module-not-found) - Case-sensitive imports, dependencies, aliases, and deployment failures.
- [Supabase Auth Redirect Not Working](https://www.iloveblogs.blog/post/supabase-auth-redirect-fix) - OAuth callbacks, magic links, redirect allowlists, and App Router fixes.
- [Drizzle ORM](https://orm.drizzle.team/docs/overview) - Type-safe SQL ORM for SQL-first teams.
- [Prisma ORM](https://www.prisma.io/docs/orm) - Schema modeling, migrations, and generated client workflows.
- [Supabase Pricing](https://supabase.com/pricing) - Official pricing reference for project limits and paid features.
- [Next.js Server Actions vs API Routes](https://www.iloveblogs.blog/post/nextjs-server-actions-vs-api-routes) - When to use Server Actions, route handlers, and API routes.
- [Next.js Authentication Comparison](https://www.iloveblogs.blog/post/nextjs-authentication-comparison-2026) - Clerk, Better Auth, Supabase Auth, and Auth.js tradeoffs.
- [Supabase vs Firebase](https://www.iloveblogs.blog/post/supabase-vs-firebase-2026-complete-comparison) - Database, Auth, real-time, storage, pricing, and developer experience.

## Tools

| Tool            | Use It For                                                                          |
| --------------- | ----------------------------------------------------------------------------------- |
| Supabase CLI    | Local stack, migrations, database reset, seed data, generated types.                |
| Playwright      | Auth flows, billing flows, regression tests, and deployment smoke tests.            |
| Sentry          | Server/client errors, traces, releases, and production exception context.           |
| Vercel Logs     | Route handler failures, deployment issues, middleware behavior, and runtime errors. |
| Stripe CLI      | Local webhook testing and event replay before production billing.                   |
| Chrome DevTools | Cookie, redirect, request header, and failed API debugging.                         |

## Community

This project gets better when developers add real production failures, maintained tools, and clearer references back into the index.

| Project Area                              | Use It For                                                                            |
| ----------------------------------------- | ------------------------------------------------------------------------------------- |
| [Community Guide](docs/community.md)      | How to contribute, suggest incidents, report outdated resources, and propose tooling. |
| [Good First Issues](GOOD_FIRST_ISSUES.md) | Small contribution ideas for links, incidents, descriptions, and verification notes.  |
| [Resource Requests](RESOURCE_REQUESTS.md) | Open areas where better docs, tools, examples, or starter kits would help.            |

- [GitHub Issues](https://github.com/mahdibrr/awesome-nextjs-supabase/issues) - Suggest resources, report broken links, or describe a production failure.
- [GitHub Pull Requests](https://github.com/mahdibrr/awesome-nextjs-supabase/pulls) - Add fixes, examples, checklists, or clearer debugging notes.
- [Supabase GitHub Discussions](https://github.com/orgs/supabase/discussions) - Community patterns and platform questions.
- [Next.js GitHub Discussions](https://github.com/vercel/next.js/discussions) - Framework questions, RFCs, and App Router behavior.

Good contributions are specific, tested, and useful to someone shipping a real application.

Help is especially welcome around RLS incidents, deployment failures, SaaS starter kits, monitoring tools, Auth edge cases, Stripe billing reliability, and Realtime behavior.

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

Helpful additions usually include:

- A real production symptom.
- The likely root cause.
- A fix or verification step.
- A link to official docs, a maintained open-source project, or a high-quality engineering writeup.

Please avoid shallow listicles, duplicate resources, keyword stuffing, and anything that does not help developers build, debug, or operate real applications.

MIT licensed. Independent community resource, not affiliated with Vercel, Next.js, or Supabase.
