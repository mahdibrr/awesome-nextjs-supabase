# Awesome Next.js + Supabase Production Resources

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
[![Link Check](https://github.com/mahdibrr/awesome-nextjs-supabase/actions/workflows/link-check.yml/badge.svg)](https://github.com/mahdibrr/awesome-nextjs-supabase/actions/workflows/link-check.yml)
[![Next.js](https://img.shields.io/badge/Next.js-15%20%2F%2016-black?logo=nextdotjs)](https://nextjs.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres%20%2B%20Auth%20%2B%20Realtime-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A curated, production-focused collection of Next.js + Supabase guides, starter kits, debugging fixes, and real-world architecture patterns.

Use it when you are building real apps with **Next.js**, **Supabase**, **Postgres**, **RLS**, **Stripe**, **App Router**, and modern SaaS infrastructure.

Main site: [iloveblogs.blog](https://www.iloveblogs.blog)

Last updated: May 2026

If this repo helps you, consider giving it a ⭐.

---

## ⭐ Why this exists

Most tutorials show a happy-path demo, then stop before the problems that appear in production.

Developers building with Next.js + Supabase often get stuck on the same hard parts:

- Auth sessions, redirects, cookies, and middleware
- Row Level Security policies that return empty data
- SaaS architecture, teams, roles, billing, and webhooks
- Deployment, caching, performance, and production debugging

This repo exists to collect the resources that solve those real problems, not just beginner setup steps.

---

## Use Cases

| Use Case | Start Here |
|---|---|
| Build SaaS apps | [SaaS Architecture](#saas-architecture), [Starter Kits](content/starter-kits/README.md), [Production Checklists](content/production-checklists/README.md) |
| Learn Supabase auth | [Supabase Auth & Security](#supabase-auth--security), [Learning Paths](content/learning-paths/README.md), [Debugging Playbook](content/debugging-playbook/README.md) |
| Fix production issues | [Problem Solver](#problem-solver), [Debugging Playbook](content/debugging-playbook/README.md), [Snippets](content/snippets/README.md) |
| Speed up development | [Starter Kits](content/starter-kits/README.md), [Snippets](content/snippets/README.md), [Open Source Examples](content/open-source-examples/README.md) |

---

## 🚀 Quick Start Navigation

| Learning Paths | Starter Kits | Debugging | Checklists | Snippets |
|---|---|---|---|---|
| [7-day roadmap](content/learning-paths/README.md) | [Starter ideas](content/starter-kits/README.md) | [Debugging playbook](content/debugging-playbook/README.md) | [Production checks](content/production-checklists/README.md) | [Code snippets](content/snippets/README.md) |

---

## 🔥 Most Useful Sections

| Section | Why It Matters |
|---|---|
| [Auth](#supabase-auth--security) | SSR sessions, OAuth, middleware, redirects, and production auth flows. |
| [RLS](#database-rls--postgres) | Policies, tenant isolation, silent failures, and secure database access. |
| [SaaS Architecture](#saas-architecture) | Multi-tenancy, background jobs, launch checklists, scaling, and product structure. |
| [Stripe Integration](#stripe--billing) | Subscriptions, billing state, webhooks, and paid feature access. |

---

## 📚 Documentation Hub

The repo now includes a structured documentation hub under [`content/`](content/README.md):

- [Learning Paths](content/learning-paths/README.md) - 7-day plan plus beginner, intermediate, and advanced roadmap.
- [Starter Kits](content/starter-kits/README.md) - SaaS, auth, Stripe, realtime, and admin dashboard starter ideas.
- [Open Source Examples](content/open-source-examples/README.md) - Real GitHub projects using Next.js and Supabase.
- [Production Checklists](content/production-checklists/README.md) - Auth, RLS, deployment, Stripe, performance, and security checks.
- [Snippets](content/snippets/README.md) - Supabase auth, middleware, RLS, and API helper snippets.
- [Debugging Playbook](content/debugging-playbook/README.md) - Common auth, RLS, hydration, and API connection issues.

---

## Start Here

| Goal | Recommended Resource |
|---|---|
| Build a SaaS app | [Complete Guide to Building SaaS with Next.js and Supabase](https://www.iloveblogs.blog/guides/building-saas-nextjs-supabase) |
| Understand App Router | [Next.js App Router Complete Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide) |
| Add production auth | [Supabase Authentication with Next.js 15 Complete Production Guide](https://www.iloveblogs.blog/guides/supabase-auth-nextjs-complete-guide-2026) |
| Secure database access | [Supabase RLS Policy Design Patterns](https://www.iloveblogs.blog/guides/supabase-rls-policy-design-patterns) |
| Deploy safely | [Deploying Next.js + Supabase to Production](https://www.iloveblogs.blog/guides/deploying-nextjs-supabase-production) |
| Launch checklist | [Next.js + Supabase Production Launch Checklist](https://www.iloveblogs.blog/guides/nextjs-supabase-production-launch-checklist) |

---

## Learning Paths

| Path | Read These |
|---|---|
| First full-stack app | [Full-Stack App Tutorial](https://www.iloveblogs.blog/post/build-fullstack-app-nextjs-supabase-step-by-step), [App Router Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide), [Supabase Auth Guide](https://www.iloveblogs.blog/guides/supabase-auth-nextjs-complete-guide-2026) |
| Production auth | [SSR Session Management](https://www.iloveblogs.blog/guides/nextjs-supabase-ssr-session-management), [Auth Middleware](https://www.iloveblogs.blog/guides/supabase-auth-complete-session-middleware-guide), [Google OAuth](https://www.iloveblogs.blog/guides/supabase-google-oauth-nextjs-15-complete-guide), [RLS Patterns](https://www.iloveblogs.blog/guides/supabase-rls-policy-design-patterns) |
| SaaS launch | [SaaS Guide](https://www.iloveblogs.blog/guides/building-saas-nextjs-supabase), [Multi-Tenant SaaS](https://www.iloveblogs.blog/guides/nextjs-supabase-multi-tenant-saas-architecture), [Stripe Subscriptions](https://www.iloveblogs.blog/guides/nextjs-supabase-stripe-subscriptions-guide), [Launch Checklist](https://www.iloveblogs.blog/guides/nextjs-supabase-production-launch-checklist) |
| Performance | [Performance Guide](https://www.iloveblogs.blog/guides/nextjs-performance-optimization), [Caching Strategies](https://www.iloveblogs.blog/guides/nextjs-supabase-caching-strategies), [Next.js 15 Caching](https://www.iloveblogs.blog/post/nextjs-15-caching-explained), [Supabase Slow Queries](https://www.iloveblogs.blog/post/supabase-slow-queries-fix) |
| AI search | [AI Integration](https://www.iloveblogs.blog/guides/ai-integration-nextjs-supabase), [pgvector Semantic Search](https://www.iloveblogs.blog/guides/nextjs-supabase-pgvector-advanced-search) |
| Reliability | [Testing Guide](https://www.iloveblogs.blog/guides/nextjs-supabase-testing-strategies), [CI/CD Guide](https://www.iloveblogs.blog/guides/nextjs-supabase-cicd-github-actions-production), [Observability](https://www.iloveblogs.blog/guides/nextjs-supabase-error-handling-observability), [Webhooks](https://www.iloveblogs.blog/guides/nextjs-supabase-webhook-event-architecture) |

---

## Problem Solver

| If This Breaks | Start Here |
|---|---|
| Supabase auth redirects fail | [Supabase Auth Redirect Not Working in Next.js App Router](https://www.iloveblogs.blog/post/supabase-auth-redirect-fix) |
| Sessions disappear after refresh | [Fix Supabase Auth Session Not Persisting After Refresh](https://www.iloveblogs.blog/post/fix-supabase-auth-session-persistence) |
| RLS returns empty data | [Why Your Supabase RLS Policies Are Silently Failing](https://www.iloveblogs.blog/post/supabase-rls-silent-failures-debug) |
| Next.js build fails after deploy | [Fix Next.js Module Not Found After Deploy or Production Build](https://www.iloveblogs.blog/post/nextjs-build-module-not-found) |
| Turbopack hangs while compiling | [Next.js Turbopack Stuck Compiling](https://www.iloveblogs.blog/post/nextjs-turbopack-stuck-fix) |
| Hydration errors appear in App Router | [Next.js Hydration Mismatch Error](https://www.iloveblogs.blog/post/nextjs-hydration-mismatch-fix) |
| Supabase queries are slow | [Why Your Supabase Queries Are Slow](https://www.iloveblogs.blog/post/supabase-slow-queries-fix) |
| Email confirmations are not sending | [Supabase Email Confirmation Not Sending](https://www.iloveblogs.blog/post/supabase-email-confirmation-fix) |

---

## Contents

- [Why this exists](#-why-this-exists)
- [Use Cases](#use-cases)
- [Quick Start Navigation](#-quick-start-navigation)
- [Most Useful Sections](#-most-useful-sections)
- [Documentation Hub](#-documentation-hub)
- [Official References](#official-references)
- [Core Guides](#core-guides)
- [Next.js App Router](#nextjs-app-router)
- [Supabase Auth & Security](#supabase-auth--security)
- [Database, RLS & Postgres](#database-rls--postgres)
- [SaaS Architecture](#saas-architecture)
- [Stripe & Billing](#stripe--billing)
- [Realtime Apps](#realtime-apps)
- [Performance & Caching](#performance--caching)
- [AI, pgvector & RAG](#ai-pgvector--rag)
- [Testing, CI/CD & Deployment](#testing-cicd--deployment)
- [Production Fixes](#production-fixes)
- [Comparisons & Decision Guides](#comparisons--decision-guides)
- [Contributing](#contributing)

---

## Official References

Use these primary references alongside the curated guides:

- [Next.js Documentation](https://nextjs.org/docs)
- [Next.js App Router](https://nextjs.org/docs/app)
- [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Supabase SSR Auth](https://supabase.com/docs/guides/auth/server-side)
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Stripe Billing](https://docs.stripe.com/billing)
- [Vercel Next.js Deployment](https://vercel.com/docs/frameworks/nextjs)

---

## Core Guides

- [Complete Guide to Building SaaS with Next.js and Supabase](https://www.iloveblogs.blog/guides/building-saas-nextjs-supabase) - End-to-end SaaS architecture, database design, auth, deployment, and production concerns.
- [Next.js App Router Complete Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide) - Routing, layouts, Server Components, loading states, data fetching, and advanced patterns.
- [Supabase Authentication & Authorization Patterns](https://www.iloveblogs.blog/guides/supabase-authentication-authorization) - Email/password auth, magic links, OAuth, RBAC, RLS, and authorization models.
- [Deploying Next.js + Supabase to Production](https://www.iloveblogs.blog/guides/deploying-nextjs-supabase-production) - Vercel deployment, environment variables, database migrations, CI/CD, and scaling.
- [Scaling Next.js + Supabase from 0 to 100K Users](https://www.iloveblogs.blog/guides/scaling-nextjs-supabase-0-to-100k-users-playbook) - Connection pooling, caching, queues, read replicas, and production scaling tradeoffs.

---

## Next.js App Router

- [Next.js App Router Complete Guide](https://www.iloveblogs.blog/guides/nextjs-app-router-complete-guide)
- [React Server Components: Complete Deep Dive](https://www.iloveblogs.blog/guides/react-server-components-deep-dive)
- [Next.js 15 Middleware Complete Guide](https://www.iloveblogs.blog/guides/nextjs-15-middleware-patterns-complete-guide)
- [Next.js 15 Partial Prerendering Complete Guide](https://www.iloveblogs.blog/guides/nextjs-15-partial-prerendering-complete-guide)
- [Next.js Server Actions with Supabase](https://www.iloveblogs.blog/guides/nextjs-server-actions-supabase-complete-guide)
- [Next.js Data Fetching Patterns with Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-data-fetching-patterns)
- [Next.js App Router + Supabase SSR Session Management](https://www.iloveblogs.blog/guides/nextjs-supabase-ssr-session-management)

---

## Supabase Auth & Security

- [Supabase Authentication with Next.js 15 Complete Production Guide](https://www.iloveblogs.blog/guides/supabase-auth-nextjs-complete-guide-2026)
- [Supabase Auth + Middleware: Complete Session Management Guide](https://www.iloveblogs.blog/guides/supabase-auth-complete-session-middleware-guide)
- [Advanced Authentication Patterns with Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-advanced-authentication-patterns)
- [Supabase + Google OAuth on Next.js 15](https://www.iloveblogs.blog/guides/supabase-google-oauth-nextjs-15-complete-guide)
- [Next.js + Supabase Security Best Practices](https://www.iloveblogs.blog/guides/nextjs-supabase-security-best-practices)
- [Supabase RLS Policy Design Patterns](https://www.iloveblogs.blog/guides/supabase-rls-policy-design-patterns)

---

## Database, RLS & Postgres

- [Database Design and Optimization for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-database-design-optimization)
- [Database Migration Strategies for Production Supabase Apps](https://www.iloveblogs.blog/guides/nextjs-supabase-migration-strategies)
- [Supabase Postgres Functions and Triggers](https://www.iloveblogs.blog/guides/supabase-postgres-functions-triggers-guide)
- [Supabase Connection Pooling with PgBouncer on Vercel](https://www.iloveblogs.blog/guides/supabase-connection-pooling-vercel)
- [Complete Type Safety Guide for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-type-safety-guide)
- [Why Your Supabase RLS Policies Are Silently Failing](https://www.iloveblogs.blog/post/supabase-rls-silent-failures-debug)
- [Debugging Supabase RLS Issues](https://www.iloveblogs.blog/post/debugging-supabase-rls-issues)
- [Why Your Supabase Queries Are Slow](https://www.iloveblogs.blog/post/supabase-slow-queries-fix)

---

## SaaS Architecture

- [Complete Guide to Building SaaS with Next.js and Supabase](https://www.iloveblogs.blog/guides/building-saas-nextjs-supabase)
- [Multi-Tenant SaaS Architecture with Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-multi-tenant-saas-architecture)
- [Next.js + Supabase Production Launch Checklist](https://www.iloveblogs.blog/guides/nextjs-supabase-production-launch-checklist)
- [Background Jobs and Async Task Patterns](https://www.iloveblogs.blog/guides/nextjs-supabase-background-jobs-async-patterns)
- [Next.js Webhook Handling and Event-Driven Architecture](https://www.iloveblogs.blog/guides/nextjs-supabase-webhook-event-architecture)
- [7 Next.js + Supabase Architecture Decisions I Would Make Differently](https://www.iloveblogs.blog/post/nextjs-supabase-architecture-decisions-regrets)
- [10 Common Mistakes Building with Next.js and Supabase](https://www.iloveblogs.blog/post/nextjs-supabase-common-mistakes)
- [7 Things I Wish I Knew Before Scaling Next.js + Supabase](https://www.iloveblogs.blog/post/nextjs-supabase-lessons-learned-production)

---

## Stripe & Billing

- [Next.js & Supabase Stripe Subscriptions Guide](https://www.iloveblogs.blog/guides/nextjs-supabase-stripe-subscriptions-guide)
- [SaaS Pricing Strategies That Actually Convert in 2026](https://www.iloveblogs.blog/post/saas-pricing-strategies-2026)
- [The Hidden Costs of Building a Full-Stack B2B SaaS in 2026](https://www.iloveblogs.blog/post/hidden-costs-fullstack-saas-development-2026)

---

## Realtime Apps

- [Supabase Realtime Complete Guide](https://www.iloveblogs.blog/guides/supabase-realtime-complete-guide)
- [Build a Real-Time Chat App with Next.js 15 + Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-realtime-chat-app-complete-build)
- [Building Real-Time Collaboration Features](https://www.iloveblogs.blog/guides/nextjs-supabase-realtime-collaboration)
- [Optimistic UI Patterns with Server Actions and Supabase Realtime](https://www.iloveblogs.blog/guides/nextjs-supabase-optimistic-ui-patterns)
- [Supabase Realtime Gotchas: 7 Issues and How to Fix Them](https://www.iloveblogs.blog/post/supabase-realtime-gotchas-solutions)

---

## Performance & Caching

- [Next.js Performance Optimization for Indie Developers](https://www.iloveblogs.blog/guides/nextjs-performance-optimization)
- [Advanced Caching Strategies for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-caching-strategies)
- [Next.js 15 Caching Explained](https://www.iloveblogs.blog/post/nextjs-15-caching-explained)
- [Next.js + Supabase Performance: 7 Fixes That Cut Load Time 70%](https://www.iloveblogs.blog/post/nextjs-supabase-performance-optimization-2026)
- [Next.js Performance Optimization: 10 Essential Techniques](https://www.iloveblogs.blog/post/nextjs-performance-10-techniques-2026)
- [I Tanked My Core Web Vitals Score With Next.js Images. Here Is How I Fixed It](https://www.iloveblogs.blog/post/nextjs-image-layout-shift-cls-fix)
- [My Next.js App Showed Stale Data for Hours Until I Fixed Cache Revalidation](https://www.iloveblogs.blog/post/nextjs-stale-cache-revalidation-fix)

---

## AI, pgvector & RAG

- [AI Integration for Next.js + Supabase Applications](https://www.iloveblogs.blog/guides/ai-integration-nextjs-supabase)
- [Mastering Supabase pgvector for Semantic Search in Next.js](https://www.iloveblogs.blog/guides/nextjs-supabase-pgvector-advanced-search)
- [AI Coding Assistants: Revolution or Hype?](https://www.iloveblogs.blog/post/ai-coding-assistants-productivity)

---

## Testing, CI/CD & Deployment

- [Testing Next.js + Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-testing-strategies)
- [Next.js & Supabase CI/CD Pipelines with GitHub Actions](https://www.iloveblogs.blog/guides/nextjs-supabase-cicd-github-actions-production)
- [Deploying Next.js + Supabase to Production](https://www.iloveblogs.blog/guides/deploying-nextjs-supabase-production)
- [Deploy Next.js 15 to Vercel Without Environment Variable Errors](https://www.iloveblogs.blog/post/nextjs-vercel-env-variables-fix)
- [Error Handling and Observability for Next.js and Supabase](https://www.iloveblogs.blog/guides/nextjs-supabase-error-handling-observability)

---

## Production Fixes

These are practical debugging guides for problems that usually appear after a project leaves the tutorial stage.

- [Next.js Hydration Mismatch Error: Exact Fixes for App Router and React](https://www.iloveblogs.blog/post/nextjs-hydration-mismatch-fix)
- [Fix Next.js Module Not Found After Deploy or Production Build](https://www.iloveblogs.blog/post/nextjs-build-module-not-found)
- [Next.js Turbopack Stuck Compiling: 9 Fixes](https://www.iloveblogs.blog/post/nextjs-turbopack-stuck-fix)
- [Fix Supabase Auth Session Not Persisting After Refresh](https://www.iloveblogs.blog/post/fix-supabase-auth-session-persistence)
- [Supabase Auth Redirect Not Working in Next.js App Router](https://www.iloveblogs.blog/post/supabase-auth-redirect-fix)
- [Handle Supabase Auth Errors in Next.js Middleware](https://www.iloveblogs.blog/post/handle-supabase-auth-errors-middleware)
- [Supabase Email Confirmation Not Sending](https://www.iloveblogs.blog/post/supabase-email-confirmation-fix)
- [Why Your Supabase RLS Policies Are Silently Failing](https://www.iloveblogs.blog/post/supabase-rls-silent-failures-debug)
- [Why Your Supabase Queries Are Slow](https://www.iloveblogs.blog/post/supabase-slow-queries-fix)

---

## Comparisons & Decision Guides

- [Next.js 15 vs 14: Real Benchmarks and Whether to Upgrade](https://www.iloveblogs.blog/post/nextjs-15-vs-14-performance-2026)
- [Next.js Server Actions vs API Routes](https://www.iloveblogs.blog/post/nextjs-server-actions-vs-api-routes)
- [Next.js Authentication Comparison 2026](https://www.iloveblogs.blog/post/nextjs-authentication-comparison-2026)
- [Supabase vs Firebase in 2026](https://www.iloveblogs.blog/post/supabase-vs-firebase-2026-complete-comparison)
- [Supabase vs Firebase Authentication](https://www.iloveblogs.blog/post/supabase-vs-firebase-auth-2026)
- [Supabase Free Tier Limits in 2026](https://www.iloveblogs.blog/post/supabase-free-tier-limits-2026)
- [Why Developers Are Switching from Firebase to Supabase](https://www.iloveblogs.blog/post/why-developers-switching-firebase-to-supabase)
- [TypeScript Migration Guide 2026](https://www.iloveblogs.blog/post/typescript-javascript-migration-guide-2026)

---

## Stats

Current curated inventory:

| Type | Count |
|---|---:|
| Guides | 45 |
| Posts | 53 |
| Total | 98 |

---

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

Good additions should be:

- Specific to Next.js, Supabase, Postgres, RLS, SaaS, AI/RAG, Stripe, deployment, or production debugging
- Practical and implementation-focused
- Useful for developers building real applications
- Free from keyword stuffing or generic AI filler

Please avoid adding shallow listicles, duplicate tutorials, or resources that do not help developers ship production apps.

---

## License

MIT. See [LICENSE](LICENSE).

---

## Disclaimer

This project is an independent curated resource. It is not affiliated with Vercel, Next.js, or Supabase.
