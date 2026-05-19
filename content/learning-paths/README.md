# Learning Paths

Use this roadmap to move from a basic Next.js + Supabase app to production-ready SaaS patterns.

## 7-Day Next.js + Supabase Plan

| Day | Focus | Outcome |
|---|---|---|
| 1 | App Router basics | Understand layouts, pages, route handlers, Server Components, and Client Components. |
| 2 | Supabase project setup | Create a Supabase project, connect environment variables, and initialize the browser/server clients. |
| 3 | Authentication | Add sign up, sign in, sign out, session refresh, and protected routes. |
| 4 | Database and RLS | Create tables, enable RLS, write policies, and test authenticated reads/writes. |
| 5 | CRUD and file uploads | Build real forms, mutations, storage uploads, and server-side validation. |
| 6 | Realtime and background work | Add realtime subscriptions, webhooks, scheduled work, or async job patterns. |
| 7 | Production launch | Audit env vars, deployment, security, performance, backups, observability, and billing readiness. |

## Beginner Roadmap

Start here if you are still learning how the stack fits together.

- Learn Next.js App Router routing, layouts, and loading states.
- Learn when to use Server Components versus Client Components.
- Create a Supabase project and understand project URL, anon key, and service role key.
- Build a small CRUD app with one table.
- Enable Row Level Security before adding real user data.
- Deploy a simple version to Vercel.

Recommended resources:

- [Next.js App Router Complete Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide)
- [Build a Full-Stack App with Next.js and Supabase](https://www.iloveblogs.blog/post/build-fullstack-app-nextjs-supabase-step-by-step)
- [Supabase Authentication with Next.js 15 Complete Production Guide](https://www.iloveblogs.blog/guides/supabase-auth-nextjs-complete-guide-2026)

## Intermediate Roadmap

Move here once you can build a basic authenticated app.

- Add SSR-safe session handling.
- Protect pages with middleware and server-side checks.
- Write RLS policies for user-owned data and team-owned data.
- Add Zod validation around mutations.
- Add file uploads with Supabase Storage.
- Add realtime updates for the parts of the app that benefit from live sync.
- Add basic tests for auth, RLS, and important database flows.

Recommended resources:

- [Next.js App Router + Supabase SSR Session Management](https://www.iloveblogs.blog/guides/nextjs-supabase-ssr-session-management)
- [Supabase RLS Policy Design Patterns](https://www.iloveblogs.blog/guides/supabase-rls-policy-design-patterns)
- [Next.js Data Fetching Patterns with Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-data-fetching-patterns)
- [Supabase Storage: Complete Guide](https://www.iloveblogs.blog/guides/supabase-storage-file-uploads)

## Advanced Roadmap

Use this path for SaaS, scale, security, and production engineering.

- Design multi-tenant data models with strict tenant isolation.
- Use connection pooling for serverless deployments.
- Add Stripe subscriptions and webhook idempotency.
- Add structured logging, monitoring, and error reporting.
- Add CI/CD with preview deployments and migration checks.
- Add caching, invalidation, and performance budgets.
- Add AI search with embeddings and pgvector when it solves a real product problem.

Recommended resources:

- [Multi-Tenant SaaS Architecture with Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-multi-tenant-saas-architecture)
- [Supabase Connection Pooling with PgBouncer on Vercel](https://www.iloveblogs.blog/guides/supabase-connection-pooling-vercel)
- [Next.js & Supabase Stripe Subscriptions](https://www.iloveblogs.blog/guides/nextjs-supabase-stripe-subscriptions-guide)
- [Testing Next.js + Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-testing-strategies)
- [Mastering Supabase pgvector for Semantic Search in Next.js](https://www.iloveblogs.blog/guides/nextjs-supabase-pgvector-advanced-search)

## External Production Resources

Use these external references to learn from primary sources and production-grade examples.

| Resource | Type | Why It Helps |
|---|---|---|
| [Next.js Documentation](https://nextjs.org/docs) | Official docs | Core framework reference for App Router, rendering, caching, and deployment behavior. |
| [Next.js App Router](https://nextjs.org/docs/app) | Official docs | Best starting point for layouts, routing, Server Components, loading UI, and route handlers. |
| [Next.js Mutating Data](https://nextjs.org/docs/app/getting-started/mutating-data) | Official docs | Current guidance for forms, mutations, and Server Actions. |
| [Supabase Documentation](https://supabase.com/docs) | Official docs | Primary reference for Supabase Auth, Postgres, Storage, Realtime, Edge Functions, and local development. |
| [Supabase Server-Side Auth](https://supabase.com/docs/guides/auth/server-side) | Official docs | Required reading for cookie-based auth in SSR and App Router applications. |
| [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) | Official docs | Foundation for production-safe authorization in Postgres. |
| [Supabase CLI Getting Started](https://supabase.com/docs/guides/local-development/cli/getting-started) | Official tool docs | Learn local Supabase development, migrations, seed data, and environment parity. |
| [Vercel Next.js Deployment](https://vercel.com/docs/frameworks/nextjs) | Official docs | Production deployment reference for Next.js on Vercel. |
| [Stripe Billing](https://docs.stripe.com/billing) | Official docs | Billing model reference for subscriptions, invoices, customers, and pricing. |
| [GitHub Actions](https://docs.github.com/en/actions) | Official docs | CI/CD foundation for testing, deployments, and scheduled automation. |
| [vercel/next.js with-supabase example](https://github.com/vercel/next.js/tree/canary/examples/with-supabase) | GitHub repo | Official Next.js example showing Supabase integration patterns. |
| [supabase/supabase](https://github.com/supabase/supabase) | GitHub repo | Main Supabase open-source repository and issue history for platform behavior. |
