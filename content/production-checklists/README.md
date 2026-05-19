# Production Checklists

Use these checklists before shipping a real Next.js + Supabase app.

## Auth Checklist

- [ ] Email/password, OAuth, magic links, and password reset flows are tested.
- [ ] Auth callback URLs are configured for local, preview, and production domains.
- [ ] Middleware refreshes sessions without redirect loops.
- [ ] Protected pages validate the user on the server.
- [ ] Client-only auth state is not trusted for authorization.
- [ ] Logout clears local UI state and server cookies.
- [ ] Error states are user-safe and do not leak internal details.

## RLS Checklist

- [ ] RLS is enabled on every table containing user or tenant data.
- [ ] Policies are tested as `anon`, `authenticated`, and service role where appropriate.
- [ ] User-owned rows check `auth.uid()`.
- [ ] Team-owned rows check membership through a join table.
- [ ] Admin policies are explicit, not accidental.
- [ ] Inserts, selects, updates, and deletes are tested separately.
- [ ] Indexes exist for columns used inside policies.

## Deployment Checklist

- [ ] Production environment variables are set in Vercel or the deployment platform.
- [ ] Preview environment variables are separate from production where needed.
- [ ] Supabase redirect URLs include production and preview domains.
- [ ] Database migrations are repeatable.
- [ ] Build command passes locally before deployment.
- [ ] Image domains and CSP rules are configured.
- [ ] Sitemap, robots, and canonical URLs point to the production domain.

## Stripe Checklist

- [ ] Stripe webhook signing secret is configured.
- [ ] Webhook handler verifies signatures.
- [ ] Events are processed idempotently.
- [ ] Subscription status is synced into Supabase.
- [ ] Customer portal flow works for upgrades, downgrades, and cancellation.
- [ ] Paid routes check subscription status on the server.
- [ ] Test mode and live mode keys are not mixed.

## Performance Checklist

- [ ] Hero images have stable dimensions and optimized formats.
- [ ] Server Components are used for server-only data where possible.
- [ ] Expensive queries are indexed.
- [ ] Avoid N+1 Supabase queries in route handlers and pages.
- [ ] Cache behavior is explicit for static, dynamic, and user-specific data.
- [ ] Revalidation paths are tested.
- [ ] Bundle size is reviewed before shipping heavy client components.

## Security Checklist

- [ ] Service role key is never exposed to the browser.
- [ ] API routes validate input with a schema.
- [ ] Rate limiting exists for sensitive actions.
- [ ] Webhooks verify signatures.
- [ ] Admin actions verify role on the server.
- [ ] Secrets are not committed.
- [ ] Logs avoid tokens, cookies, and personally identifiable information.
- [ ] Database backups and recovery plan are understood.

## External Production Resources

Use these external references and tools to harden a real production app.

| Resource | Area | Why It Helps |
|---|---|---|
| [Next.js Production Checklist](https://nextjs.org/docs/pages/guides/production-checklist) | Deployment | Official Next.js launch checklist for performance, security, and reliability. |
| [Vercel Production Checklist](https://vercel.com/docs/production-checklist) | Deployment | Production readiness checks for Vercel-hosted applications. |
| [Vercel Next.js Deployment](https://vercel.com/docs/frameworks/nextjs) | Deployment | Framework-specific deployment behavior, caching, and runtime reference. |
| [Supabase Going Into Production](https://supabase.com/docs/guides/deployment/going-into-prod) | Database/platform | Official Supabase production readiness guidance. |
| [Supabase Backups](https://supabase.com/docs/guides/platform/backups) | Reliability | Backup and recovery reference for production Postgres projects. |
| [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) | Security | Required reference for production authorization. |
| [Stripe Launch Checklist](https://docs.stripe.com/get-started/account/checklist) | Billing | Official Stripe readiness checklist before taking real payments. |
| [Stripe Webhooks](https://docs.stripe.com/webhooks) | Billing | Reference for secure webhook signatures, retries, and event handling. |
| [OWASP ASVS](https://github.com/OWASP/ASVS) | Security | Security verification standard for production web applications. |
| [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) | Security | Practical security checklists for auth, sessions, secrets, APIs, and logging. |
| [Sentry for Next.js](https://docs.sentry.io/platforms/javascript/guides/nextjs/) | Observability | Error monitoring setup for Next.js apps. |
| [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) | Performance | Automated Lighthouse performance checks in CI/CD. |
| [Checkly Docs](https://www.checklyhq.com/docs/) | Monitoring | Synthetic monitoring and API checks for production apps. |
