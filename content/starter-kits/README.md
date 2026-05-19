# Starter Kits

This page lists starter kit ideas that are useful for real Next.js + Supabase projects. Each idea can become a standalone repository, template, or tutorial.

## Next.js SaaS Starter

Core features:

- Next.js App Router
- Supabase Auth with SSR session handling
- Supabase Postgres schema with RLS enabled
- Team or workspace model
- Billing-ready account model
- Dashboard layout
- Settings pages
- Basic email templates
- Production deployment checklist

Good for:

- B2B SaaS products
- Internal tools
- Membership apps
- Paid dashboards

## Supabase Auth Starter

Core features:

- Email/password auth
- Magic link auth
- OAuth callback route
- Middleware route protection
- Server Component user lookup
- Client Component auth state
- Password reset flow
- Session refresh handling
- RLS examples for user-owned rows

Good for:

- Apps that need reliable auth before adding product features
- Developers debugging cookie/session behavior in App Router

## Stripe Billing Starter

Core features:

- Stripe Checkout
- Customer portal
- Subscription status sync
- Webhook route handler
- Idempotent webhook processing
- Supabase tables for customers, subscriptions, prices, and products
- Protected paid routes
- Billing status UI

Good for:

- SaaS subscriptions
- Paid communities
- Pro feature gates
- Usage-based billing experiments

## Realtime Chat Starter

Core features:

- Supabase Realtime channels
- Message table with RLS
- Presence tracking
- Typing indicators
- Optimistic message sending
- Read receipts
- Room membership policies
- Moderation hooks

Good for:

- Support chat
- Team collaboration
- Community products
- AI chat interfaces with persistent history

## Admin Dashboard Starter

Core features:

- Protected admin routes
- Role-based access control
- Audit log table
- User management
- Database-backed settings
- Data tables with filtering and pagination
- Server-side search
- Secure service-role-only admin actions

Good for:

- SaaS back offices
- Moderation tools
- Internal operations dashboards
- Customer support panels

## Starter Kit Quality Checklist

Before publishing a starter, make sure it includes:

- A clear README with setup steps
- `.env.example`
- Database migration files or SQL setup
- RLS policies enabled by default
- No committed secrets
- Working local development instructions
- Deployment notes for Vercel
- License file
- Screenshots or demo link

## External Starter Resources

These are real external starters, examples, and production tools worth studying before building your own starter.

| Resource | Category | Why It Helps |
|---|---|---|
| [vercel/next.js with-supabase example](https://github.com/vercel/next.js/tree/canary/examples/with-supabase) | Official example | Minimal official Next.js + Supabase integration example. |
| [vercel/nextjs-subscription-payments](https://github.com/vercel/nextjs-subscription-payments) | SaaS starter | Subscription app with Next.js, Supabase, and Stripe. |
| [makerkit/nextjs-saas-starter-kit-lite](https://github.com/makerkit/nextjs-saas-starter-kit-lite) | SaaS starter | Lite open-source SaaS starter built around Next.js and Supabase. |
| [KolbySisk/next-supabase-stripe-starter](https://github.com/KolbySisk/next-supabase-stripe-starter) | SaaS starter | Next.js, Supabase, Stripe, shadcn/ui, and billing-oriented app structure. |
| [imbhargav5/nextbase-nextjs-supabase-starter](https://github.com/imbhargav5/nextbase-nextjs-supabase-starter) | App starter | Next.js + Supabase + Tailwind starter with modern project structure. |
| [antoineross/Hikari](https://github.com/antoineross/Hikari) | SaaS starter | Open-source Next.js, Stripe, and Supabase SaaS template using App Router. |
| [michaeltroya/supa-next-starter](https://github.com/michaeltroya/supa-next-starter) | App starter | Supabase, Next.js, Tailwind, and shadcn/ui starter for dashboard-style apps. |
| [Barty-Bart/nextjs-supabase-shadcn-boilerplate](https://github.com/Barty-Bart/nextjs-supabase-shadcn-boilerplate) | Dashboard starter | Minimal Next.js + Supabase + shadcn/ui boilerplate with auth and sidebar layout. |
| [stripe-samples/checkout-single-subscription](https://github.com/stripe-samples/checkout-single-subscription) | Billing example | Official Stripe sample for single subscription checkout flows. |
| [supabase-community/nextjs-openai-doc-search](https://github.com/supabase-community/nextjs-openai-doc-search) | AI starter | Next.js, OpenAI, and Supabase template for document search. |
| [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) | Production tool | Essential for local development, migrations, database reset, and seed workflows. |
| [shadcn/ui](https://github.com/shadcn-ui/ui) | UI toolkit | Common production UI foundation for Next.js dashboards and SaaS starters. |
