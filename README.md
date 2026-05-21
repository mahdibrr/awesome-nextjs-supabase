# Awesome Supabase Resources [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

[![Link Check](https://github.com/mahdibrr/awesome-nextjs-supabase/actions/workflows/link-check.yml/badge.svg)](https://github.com/mahdibrr/awesome-nextjs-supabase/actions/workflows/link-check.yml)
[![Contributors](https://img.shields.io/github/contributors/mahdibrr/awesome-nextjs-supabase)](https://github.com/mahdibrr/awesome-nextjs-supabase/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/mahdibrr/awesome-nextjs-supabase)](https://github.com/mahdibrr/awesome-nextjs-supabase/commits/main)

A curated, production-focused collection of Next.js and Supabase resources for building SaaS products with PostgreSQL, RLS, Auth, Stripe, App Router, Server Actions, TypeScript, and Vercel.

Built for developers who need practical references, real examples, production checklists, and debugging guides beyond basic quickstarts.

## Contents

- [Recently Added](#recently-added)
- [Use Cases](#use-cases)
- [Most Common Production Failures](#most-common-production-failures)
- [Production Problems Covered](#production-problems-covered)
- [Documentation Hub](#documentation-hub)
- [Official References](#official-references)
- [Next.js and App Router](#nextjs-and-app-router)
- [Supabase Auth and Security](#supabase-auth-and-security)
- [Database, RLS, and PostgreSQL](#database-rls-and-postgresql)
- [SaaS Architecture](#saas-architecture)
- [Open Source Starters](#open-source-starters)
- [Local Development](#local-development)
- [Database Migrations and Type Generation](#database-migrations-and-type-generation)
- [Stripe and Billing](#stripe-and-billing)
- [Realtime Apps](#realtime-apps)
- [Performance and Caching](#performance-and-caching)
- [AI, pgvector, and RAG](#ai-pgvector-and-rag)
- [Testing, Monitoring, and Deployment](#testing-monitoring-and-deployment)
- [Production Fixes](#production-fixes)
- [Comparisons and Decision Guides](#comparisons-and-decision-guides)
- [Community and Discussions](#community-and-discussions)

## Recently Added

Recent foundation updates focus on community trust and practical usefulness:

- Structured documentation hub for learning paths, starter kits, production checklists, snippets, and debugging.
- External production references from official docs, trusted open-source repositories, and real developer tools.
- Link checking, contribution templates, issue templates, and clearer contribution guidance.
- Repository metadata and topics aligned with Next.js, Supabase, SaaS, RLS, Auth, Stripe, App Router, TypeScript, and Vercel.

## Use Cases

| Use Case              | Start Here                                                                              |
| --------------------- | --------------------------------------------------------------------------------------- |
| Build SaaS apps       | SaaS architecture, starter kits, Stripe billing, deployment, and production checklists. |
| Learn Supabase Auth   | Auth guides, SSR sessions, middleware, OAuth callbacks, and cookie handling.            |
| Fix production issues | Debugging playbooks for RLS, hydration errors, redirects, deployment, and API failures. |
| Speed up development  | Starter kits, snippets, open-source examples, and official docs in one place.           |

## Most Common Production Failures

Start with the [Production Incident Index](content/incidents/README.md) when debugging symptoms like "Supabase returns empty array", "Next.js auth session lost after refresh", "RLS silently fails", or "middleware redirect loop".

It maps real symptoms to likely root causes, fixes, verification steps, snippets, and references across Auth, RLS, deployment, caching, billing, database, and Realtime incidents.

## Production Problems Covered

- Auth sessions, OAuth redirects, cookies, protected routes, and middleware.
- Row Level Security policies, tenant isolation, silent failures, and policy performance.
- SaaS workspaces, roles, billing, webhooks, launch readiness, and production architecture.
- App Router data fetching, Server Components, Server Actions, caching, and deployment behavior.
- Stripe subscriptions, webhook signatures, customer portal flows, and billing state sync.
- Vercel deployment, environment variables, CI/CD, observability, and incident debugging.

## Documentation Hub

| Section                                                          | What It Covers                                                     |
| ---------------------------------------------------------------- | ------------------------------------------------------------------ |
| [Learning Paths](content/learning-paths/README.md)               | Seven-day roadmap from beginner setup to production SaaS patterns. |
| [Starter Kits](content/starter-kits/README.md)                   | SaaS, Auth, Stripe, realtime, and dashboard starter ideas.         |
| [Open Source Examples](content/open-source-examples/README.md)   | Real GitHub projects using Next.js and Supabase.                   |
| Production Incident Index                                        | Symptom-first debugging reference for common production failures.  |
| [Production Checklists](content/production-checklists/README.md) | Auth, RLS, deployment, Stripe, performance, and security checks.   |
| [Snippets](content/snippets/README.md)                           | Supabase Auth, middleware, RLS, and API helper snippets.           |
| [Debugging Playbook](content/debugging-playbook/README.md)       | Common Auth, RLS, hydration, API, and deployment fixes.            |

## Official References

- [Next.js Documentation](https://nextjs.org/docs) - Official framework reference for routing, rendering, caching, data fetching, and deployment.
- [Next.js App Router](https://nextjs.org/docs/app) - Official App Router docs for layouts, routing, loading UI, Server Components, and route handlers.
- [Next.js Server Actions](https://nextjs.org/docs/app/getting-started/mutating-data) - Official mutation and form handling reference for App Router applications.
- [Supabase Documentation](https://supabase.com/docs) - Official Supabase reference for Auth, PostgreSQL, Storage, Realtime, Edge Functions, and local development.
- [Supabase Server-Side Auth](https://supabase.com/docs/guides/auth/server-side) - Official SSR Auth reference for cookies, sessions, and server-rendered apps.
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) - Official RLS reference for secure database access.
- [Supabase Going Into Production](https://supabase.com/docs/guides/deployment/going-into-prod) - Official production-readiness guide for Supabase projects.
- [Stripe Billing](https://docs.stripe.com/billing) - Official billing reference for subscriptions, invoices, customers, and pricing models.
- [Vercel Next.js Deployment](https://vercel.com/docs/frameworks/nextjs) - Official deployment docs for Next.js on Vercel.
- [GitHub Actions](https://docs.github.com/en/actions) - Official CI/CD automation reference.

## Next.js and App Router

- [Making Sense of React Server Components](https://www.joshwcomeau.com/react/server-components/) - Clear mental model for React Server Components and how they differ from SSR.
- [Understanding React Server Components](https://vercel.com/blog/understanding-react-server-components) - Vercel's architectural breakdown of RSCs and data flow.
- [Understanding App Directory Architecture in Next.js](https://www.smashingmagazine.com/2023/02/understanding-app-directory-architecture-next-js/) - Smashing Magazine deep dive into App Router structure and tradeoffs.
- [Lee Robinson on Next.js](https://leerob.com/) - Practical writing and examples from a long-time Next.js maintainer and Vercel educator.
- [T3 Stack](https://create.t3.gg/) - Type-safe full-stack Next.js conventions for teams that want opinionated defaults.
- [Next.js App Router Complete Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide) - Routing, layouts, Server Components, loading states, and advanced patterns.

## Supabase Auth and Security

- [Supabase Auth Quickstart for Next.js](https://supabase.com/docs/guides/auth/quickstarts/nextjs) - Official quickstart for Auth setup, middleware configuration, and protected routes.
- [Build a Full-Stack App with Next.js and Supabase](https://blog.logrocket.com/build-full-stack-app-next-js-supabase/) - LogRocket walkthrough covering Auth, RLS, and deployment basics.
- [Supabase Auth UI React](https://github.com/supabase/auth-ui) - Official Auth UI components for teams that need a fast baseline before custom UI.
- [Supabase SSR Package](https://github.com/supabase/ssr) - Official server-side auth helpers for cookie-based SSR sessions.
- [Supabase Authentication and Authorization Patterns](https://www.iloveblogs.blog/guides/supabase-authentication-authorization) - Email/password Auth, magic links, OAuth, RBAC, RLS, and authorization models.
- [Supabase Auth and Middleware Session Management](https://www.iloveblogs.blog/guides/supabase-auth-complete-session-middleware-guide) - Middleware, cookies, session refresh, and route protection.
- [Next.js and Supabase Security Best Practices](https://www.iloveblogs.blog/guides/nextjs-supabase-security-best-practices) - RLS policies, secret management, API security, and Auth hardening.

## Database, RLS, and PostgreSQL

- [RLS Performance and Best Practices](https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv) - Official Supabase guide for indexing policies and avoiding slow RLS checks.
- [Supabase Security Suite](https://supabase.com/blog/hardening-supabase) - Production hardening for RLS, Column Level Security, and network restrictions.
- [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html) - Official PostgreSQL query-plan reference for debugging slow queries.
- [Supabase Database Functions](https://supabase.com/docs/guides/database/functions) - Official reference for PostgreSQL functions, security mode, and RPC patterns.
- [Supabase Connection Pooler](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler) - Required production reference for serverless and pooled database access.
- [Database Design and Optimization for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-database-design-optimization) - PostgreSQL schema design, indexing, query optimization, and scaling patterns.
- [Database Migration Strategies for Production Supabase Apps](https://www.iloveblogs.blog/guides/nextjs-supabase-migration-strategies) - Zero-downtime migrations, rollback strategies, and schema versioning.

## SaaS Architecture

- [SaaS Starter by Next.js](https://github.com/nextjs/saas-starter) - Official starter using Next.js, PostgreSQL, Drizzle ORM, Stripe, and shadcn/ui.
- [Vercel Subscription Payments](https://github.com/vercel/nextjs-subscription-payments) - Reference implementation for subscriptions with Next.js, Supabase, and Stripe.
- [Theo Browne](https://t3.gg/) - Practical opinions on full-stack TypeScript, SaaS architecture, and maintainable defaults.
- [shadcn/ui Blocks](https://ui.shadcn.com/blocks) - Production-ready dashboard and application blocks for SaaS interfaces.
- [Complete Guide to Building SaaS with Next.js and Supabase](https://www.iloveblogs.blog/guides/building-saas-nextjs-supabase) - End-to-end SaaS architecture, database design, Auth, deployment, and production concerns.
- [Multi-Tenant SaaS Architecture with Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-multi-tenant-saas-architecture) - Tenant isolation, RLS policies, subdomain routing, and billing integration.
- [Next.js and Supabase Production Launch Checklist](https://www.iloveblogs.blog/guides/nextjs-supabase-production-launch-checklist) - Production checklist across Auth, RLS, performance, observability, and deployment.

## Open Source Starters

- [Vercel with-supabase Example](https://github.com/vercel/next.js/tree/canary/examples/with-supabase) - Official Next.js and Supabase example with App Router and cookie-based Auth.
- [KolbySisk/next-supabase-stripe-starter](https://github.com/KolbySisk/next-supabase-stripe-starter) - SaaS starter with Next.js, Supabase, Stripe, React Email, and shadcn/ui.
- [makerkit/nextjs-saas-starter-kit-lite](https://github.com/makerkit/nextjs-saas-starter-kit-lite) - Lite open-source SaaS starter based on Next.js and Supabase.
- [antoineross/Hikari](https://github.com/antoineross/Hikari) - Open-source Next.js, Stripe, and Supabase SaaS template using App Router.
- [t3-oss/create-t3-app](https://github.com/t3-oss/create-t3-app) - Popular TypeScript-first Next.js starter with a strong full-stack architecture model.
- [shadcn Taxonomy](https://github.com/shadcn-ui/taxonomy) - Real-world app structure reference for Next.js, content, auth-adjacent flows, and UI composition.

## Local Development

- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) - Local projects, database reset, migrations, seeds, and generated types.
- [Supabase Local Development](https://supabase.com/docs/guides/local-development) - Official workflow for running the Supabase stack locally.
- [Next.js Environment Variables](https://nextjs.org/docs/app/guides/environment-variables) - Correct handling for server-only secrets and public client variables.
- [Vercel Environment Variables](https://vercel.com/docs/projects/environment-variables) - Production, preview, and development environment scoping.
- [shadcn/ui Installation for Next.js](https://ui.shadcn.com/docs/installation/next) - Common UI foundation for dashboards, settings pages, and SaaS workflows.
- [Docker Compose](https://docs.docker.com/compose/) - Useful baseline for local dependencies around PostgreSQL, queues, and support services.

## Database Migrations and Type Generation

- [Supabase Database Migrations](https://supabase.com/docs/guides/local-development/overview) - Official migration workflow with local development and remote projects.
- [Generating TypeScript Types](https://supabase.com/docs/guides/api/rest/generating-types) - Generate database types from Supabase schemas for safer app code.
- [Drizzle with Supabase](https://supabase.com/docs/guides/database/drizzle) - Official Supabase guide for using Drizzle ORM with a Supabase database.
- [Drizzle Migrations](https://orm.drizzle.team/docs/migrations) - Drizzle Kit migration generation and migration folder workflow.
- [Prisma with Next.js](https://www.prisma.io/docs/guides/nextjs) - Prisma's official Next.js guide for schema, queries, and deployment setup.
- [Prisma Migrate](https://www.prisma.io/docs/orm/prisma-migrate) - Migration workflow reference for teams choosing Prisma instead of direct Supabase client queries.

## Stripe and Billing

- [Stripe Webhooks](https://docs.stripe.com/webhooks) - Official reference for webhook signatures, retries, and event handling.
- [Stripe Launch Checklist](https://docs.stripe.com/get-started/account/checklist) - Official Stripe checklist before taking real payments.
- [stripe-samples/subscription-use-cases](https://github.com/stripe-samples/subscription-use-cases) - Official Stripe samples for fixed-price and usage-based subscriptions.
- [stripe-samples/checkout-single-subscription](https://github.com/stripe-samples/checkout-single-subscription) - Official sample for single-subscription checkout flows.
- [Stripe Customer Portal](https://docs.stripe.com/customer-management) - Official reference for subscription management, invoices, and customer self-service.
- [Stripe Testing](https://docs.stripe.com/testing) - Test cards, clocks, and integration checks before production billing.
- [Next.js and Supabase Stripe Subscriptions Guide](https://www.iloveblogs.blog/guides/nextjs-supabase-stripe-subscriptions-guide) - Webhooks, user syncing, gated content, and subscription state.

## Realtime Apps

- [Supabase Realtime](https://supabase.com/docs/guides/realtime) - Official reference for Broadcast, Presence, and PostgreSQL Changes.
- [Using Realtime with Next.js](https://supabase.com/docs/guides/realtime/realtime-with-nextjs) - Official Supabase guide for Realtime in Next.js applications.
- [Subscribing to Database Changes](https://supabase.com/docs/guides/realtime/subscribing-to-database-changes) - Official setup for PostgreSQL Changes, RLS requirements, and filtering.
- [Realtime Authorization](https://supabase.com/docs/guides/realtime/authorization) - Role-based authorization for Realtime channels and Broadcast.
- [Supabase Realtime Complete Guide](https://www.iloveblogs.blog/guides/supabase-realtime-complete-guide) - Chat, notifications, collaborative editing, Broadcast, Presence, and change feeds.
- [Build a Real-Time Chat App with Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-realtime-chat-app-complete-build) - Schema design, RLS policies, channels, presence, typing indicators, and messages.

## Performance and Caching

- [Vercel Data Cache for Next.js](https://vercel.com/blog/vercel-cache-api-nextjs-cache) - Deep dive into cache APIs and production caching behavior.
- [How to Maintain a Large Next.js Application](https://www.smashingmagazine.com/2021/11/maintain-large-nextjs-application/) - Smashing Magazine on organization, performance budgets, and maintainability.
- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) - Automated Lighthouse checks for performance and quality in CI.
- [Next.js Caching and Revalidating](https://nextjs.org/docs/app/getting-started/caching-and-revalidating) - Official caching model for App Router data, routes, and invalidation.
- [Vercel Speed Insights](https://vercel.com/docs/speed-insights) - Real user performance monitoring for deployed applications.
- [Next.js Performance Optimization for Indie Developers](https://www.iloveblogs.blog/guides/nextjs-performance-optimization) - Core Web Vitals, image optimization, bundle size, and caching.
- [Advanced Caching Strategies for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-caching-strategies) - Redis, ISR, SWR, cache invalidation, and performance tuning.

## AI, pgvector, and RAG

- [Supabase AI and Vectors](https://supabase.com/docs/guides/ai) - Official Supabase reference for vector search and AI workflows.
- [supabase-community/nextjs-openai-doc-search](https://github.com/supabase-community/nextjs-openai-doc-search) - Next.js, OpenAI, and Supabase template for document search.
- [mayooear/langchain-supabase-website-chatbot](https://github.com/mayooear/langchain-supabase-website-chatbot) - Website chatbot using LangChain, Supabase, TypeScript, OpenAI, and Next.js.
- [Vercel AI Chatbot](https://github.com/vercel/chatbot) - High-quality AI chat architecture reference for Next.js applications.
- [AI Integration for Next.js and Supabase Applications](https://www.iloveblogs.blog/guides/ai-integration-nextjs-supabase) - OpenAI integration, chat interfaces, vector search, and RAG systems.

## Testing, Monitoring, and Deployment

- [Vercel Production Checklist](https://vercel.com/docs/production-checklist) - Production-readiness checks for Vercel applications.
- [Vercel Runtime Logs](https://vercel.com/docs/logs/runtime) - Runtime logs for production debugging and deployment visibility.
- [Playwright](https://playwright.dev/docs/intro) - End-to-end testing framework for browser flows.
- [Playwright Test Configuration](https://playwright.dev/docs/test-configuration) - Configure projects, retries, web servers, and CI-friendly browser tests.
- [Sentry for Next.js](https://docs.sentry.io/platforms/javascript/guides/nextjs/) - Error monitoring setup for Next.js apps.
- [LogRocket Blog](https://blog.logrocket.com/) - Practical debugging and frontend production articles.
- [PostHog Docs](https://posthog.com/docs) - Product analytics, feature flags, session replay, and funnels for SaaS apps.
- [Checkly](https://www.checklyhq.com/docs/) - Synthetic monitoring and API checks for production apps.
- [Testing Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-testing-strategies) - Unit, integration, RLS, and E2E testing strategies.

## Production Fixes

- [Next.js Hydration Error Guide](https://nextjs.org/docs/messages/react-hydration-error) - Official guide to hydration mismatch causes and fixes.
- [Supabase Troubleshooting](https://supabase.com/docs/guides/troubleshooting) - Official troubleshooting entry point for platform and project issues.
- [Chrome DevTools Network Panel](https://developer.chrome.com/docs/devtools/network/) - Debug failed requests, redirects, cookies, headers, and responses.
- [Sentry Tracing](https://docs.sentry.io/platforms/javascript/guides/nextjs/tracing/) - Trace slow requests, route handlers, and client interactions.
- [Next.js Hydration Mismatch Error Fixes](https://www.iloveblogs.blog/post/nextjs-hydration-mismatch-fix) - App Router and React causes, diagnostics, and fixes.
- [Fix Next.js Module Not Found After Deploy](https://www.iloveblogs.blog/post/nextjs-build-module-not-found) - Case-sensitive imports, missing dependencies, path aliases, and deployment failures.
- [Supabase Auth Redirect Not Working](https://www.iloveblogs.blog/post/supabase-auth-redirect-fix) - OAuth callbacks, magic links, redirect allowlists, and App Router fixes.

## Comparisons and Decision Guides

- [Drizzle ORM](https://orm.drizzle.team/docs/overview) - Type-safe SQL ORM with a lightweight model for teams that prefer SQL-first workflows.
- [Prisma ORM](https://www.prisma.io/docs/orm) - Mature ORM documentation for schema modeling, migrations, and generated client workflows.
- [Supabase Pricing](https://supabase.com/pricing) - Official pricing reference for project limits and paid features.
- [Next.js Server Actions vs API Routes](https://www.iloveblogs.blog/post/nextjs-server-actions-vs-api-routes) - When to use Server Actions, route handlers, and traditional API routes.
- [Next.js Authentication Comparison](https://www.iloveblogs.blog/post/nextjs-authentication-comparison-2026) - Clerk, Better Auth, Supabase Auth, and Auth.js tradeoffs.
- [Supabase vs Firebase](https://www.iloveblogs.blog/post/supabase-vs-firebase-2026-complete-comparison) - Database, Auth, real-time, storage, pricing, and developer experience.

## Community and Discussions

- [GitHub Issues](https://github.com/mahdibrr/awesome-nextjs-supabase/issues) - Suggest resources, report broken links, or request new sections.
- [GitHub Pull Requests](https://github.com/mahdibrr/awesome-nextjs-supabase/pulls) - Contribute fixes, new resources, and maintenance updates.
- [Supabase GitHub Discussions](https://github.com/orgs/supabase/discussions) - Community discussion for Supabase platform questions and patterns.
- [Next.js GitHub Discussions](https://github.com/vercel/next.js/discussions) - Community discussion for Next.js questions, RFCs, and App Router behavior.

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

Good additions are practical, implementation-focused, and directly useful to developers shipping production apps with Next.js, Supabase, PostgreSQL, RLS, SaaS, Auth, Stripe, App Router, TypeScript, or Vercel.

Please avoid shallow listicles, duplicate resources, and anything that does not help developers build, debug, or operate real applications.

MIT licensed. Independent community resource, not affiliated with Vercel, Next.js, or Supabase.
