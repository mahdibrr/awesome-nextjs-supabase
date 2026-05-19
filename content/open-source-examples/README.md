# Open Source Examples

Real GitHub projects are useful because they show how the stack behaves outside isolated snippets. Use these examples to study folder structure, auth flows, schemas, deployment choices, and product tradeoffs.

## SaaS Apps

- [vercel/nextjs-subscription-payments](https://github.com/vercel/nextjs-subscription-payments) - SaaS subscription app using Next.js, Supabase, and Stripe.
- [makerkit/nextjs-saas-starter-kit-lite](https://github.com/makerkit/nextjs-saas-starter-kit-lite) - Lite SaaS starter kit based on Next.js and Supabase.
- [KolbySisk/next-supabase-stripe-starter](https://github.com/KolbySisk/next-supabase-stripe-starter) - Next.js, Supabase, Stripe, and shadcn/ui SaaS starter.
- [antoineross/Hikari](https://github.com/antoineross/Hikari) - Open-source Next.js, Stripe, and Supabase SaaS starter using App Router.
- [adrianhajdin/saas-app](https://github.com/adrianhajdin/saas-app) - LMS SaaS app with Next.js, Supabase, Stripe, and AI voice features.

## Dashboards

- [e2b-dev/dashboard](https://github.com/e2b-dev/dashboard) - Dashboard for managing E2B sandboxes and API keys, built with Next.js and Supabase.
- [taiwo-adewale/ecommerce-admin](https://github.com/taiwo-adewale/ecommerce-admin) - E-commerce admin dashboard using Next.js, shadcn/ui, React Query, and Supabase.
- [Barty-Bart/nextjs-supabase-shadcn-boilerplate](https://github.com/Barty-Bart/nextjs-supabase-shadcn-boilerplate) - Minimal Next.js, Supabase, and shadcn/ui boilerplate with auth and dashboard sidebar.
- [w3labkr/nextjs14-supabase-blog](https://github.com/w3labkr/nextjs14-supabase-blog) - Dashboard-oriented Next.js 14 App Router starter using Supabase and shadcn/ui.

## Chat Apps

- [supabase-community/nextjs-openai-doc-search](https://github.com/supabase-community/nextjs-openai-doc-search) - ChatGPT-style document search powered by Next.js, OpenAI, and Supabase.
- [mayooear/langchain-supabase-website-chatbot](https://github.com/mayooear/langchain-supabase-website-chatbot) - Website chatbot using LangChain, Supabase, TypeScript, OpenAI, and Next.js.
- [nolly-studio/ai-chatbot-supabase](https://github.com/nolly-studio/ai-chatbot-supabase) - Next.js and Supabase AI chatbot forked from the Vercel AI chatbot.
- [ibelick/zola](https://github.com/ibelick/zola) - Open chat interface for multiple AI models with Supabase in the stack.

## AI Apps With Supabase

- [supabase-community/nextjs-openai-doc-search](https://github.com/supabase-community/nextjs-openai-doc-search) - Reference implementation for AI document search with embeddings.
- [mayooear/langchain-supabase-website-chatbot](https://github.com/mayooear/langchain-supabase-website-chatbot) - LangChain chatbot backed by Supabase.
- [nolly-studio/cult-directory-template](https://github.com/nolly-studio/cult-directory-template) - Next.js, Supabase, directory template, admin features, and AI-oriented product patterns.
- [onlook-dev/onlook](https://github.com/onlook-dev/onlook) - Open-source AI-first visual editor built with React/Next.js patterns and Supabase in the stack.

## How To Evaluate Examples

Before copying an approach, check:

- Is the repo maintained?
- Does it use App Router or Pages Router?
- Does it use current Supabase SSR auth helpers?
- Are RLS policies included?
- Are migrations included?
- Are service role keys kept server-only?
- Are Stripe webhooks idempotent?
- Does the README explain deployment clearly?

## External Reference Resources

Use these official docs, repos, and tools when reviewing or extending open-source examples.

| Resource | Type | Why It Helps |
|---|---|---|
| [Next.js App Router](https://nextjs.org/docs/app) | Official docs | Helps identify whether an example uses current App Router patterns. |
| [Supabase Server-Side Auth](https://supabase.com/docs/guides/auth/server-side) | Official docs | Useful for checking whether a repo handles cookies and sessions correctly. |
| [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) | Official docs | Use it to evaluate whether the database access model is production-safe. |
| [Supabase Realtime](https://supabase.com/docs/guides/realtime) | Official docs | Reference for chat, presence, broadcast, and collaborative examples. |
| [Supabase Storage](https://supabase.com/docs/guides/storage) | Official docs | Reference for apps with uploads, avatars, media, or document storage. |
| [supabase/supabase-js](https://github.com/supabase/supabase-js) | GitHub repo | Official JavaScript client used by most Next.js + Supabase examples. |
| [supabase/ssr](https://github.com/supabase/ssr) | GitHub repo | Official SSR package for current cookie/session handling. |
| [vercel/next.js examples](https://github.com/vercel/next.js/tree/canary/examples/with-supabase) | GitHub repo | Official example to compare against community implementations. |
| [vercel/chatbot](https://github.com/vercel/chatbot) | GitHub repo | High-quality AI chat architecture reference for Next.js applications. |
| [Playwright](https://playwright.dev/docs/intro) | Production tool | Useful for checking whether an example can support end-to-end tests. |
| [Sentry for Next.js](https://docs.sentry.io/platforms/javascript/guides/nextjs/) | Production tool | Reference for adding error monitoring to example apps. |
| [PostHog Docs](https://posthog.com/docs) | Production tool | Product analytics reference for SaaS and dashboard examples. |
