# CLAUDE.md — awesome-nextjs-supabase

## What This Repo Is

A curated **"awesome list"** of production-focused Next.js + Supabase resources. It is **not a codebase** — it is a structured collection of links (guides, posts, snippets, checklists) organized for developers building real SaaS apps.

---

## Repo Structure

```
README.md                  # Master list — the main entry point
CONTRIBUTING.md            # Contribution rules
.lychee.toml               # Link-checker config (CI)
.github/
  workflows/link-check.yml # Automated broken-link CI
  ISSUE_TEMPLATE/
  PULL_REQUEST_TEMPLATE.md
content/
  README.md                # Hub index
  learning-paths/          # 7-day roadmap, beginner → advanced
  starter-kits/            # SaaS, auth, Stripe, realtime starters
  open-source-examples/    # Real GitHub projects using Next.js + Supabase
  production-checklists/   # Auth, RLS, deployment, Stripe, perf, security
  snippets/                # Code snippets: auth, middleware, RLS, API helpers
  debugging-playbook/      # Auth, RLS, hydration, API connection fixes
```

---

## Content Scope

Resources must be specific to one or more of:

- Next.js (App Router, Server Components, middleware, caching, Server Actions)
- Supabase (auth, RLS, Postgres, realtime, pgvector, Edge Functions)
- SaaS architecture (multi-tenancy, billing, webhooks, background jobs)
- Stripe subscriptions
- Production debugging, CI/CD, deployment (Vercel), observability

**Reject:** generic listicles, thin AI filler, duplicates, unrelated topics.

---

## How Resources Are Added

1. Add a bullet to the correct section in `README.md` (or the relevant `content/*/README.md`).
2. Format: `- [Title](url) - Short description of the production problem it solves.`
3. Keep descriptions concrete — what specific problem does this solve?
4. Run link check before opening a PR.

---

## CI

- **Link checker:** `.github/workflows/link-check.yml` uses [lychee](https://github.com/lycheeverse/lychee) with config in `.lychee.toml`.
- Accepts HTTP 200/204/206/301/302/429 (429 avoids false positives from rate limits).
- 2 retries, 20s timeout.

---

## Stats (as of June 2026)

| Type | Count |
|--------|------:|
| Third-party resources (official docs, repos, tools) | ~103 |
| iloveblogs.blog guides + posts | 16 |
| Total unique links | ~119 |

Counts are unique URLs across `README.md` and `content/**`. Third-party sources outnumber blog links roughly 6:1.

---

## What Claude Should Help With

- **Adding resources:** find the right section in README.md or a content sub-file, format the bullet correctly.
- **Editing descriptions:** keep them practical and specific, no keyword stuffing.
- **Maintaining structure:** sections in README.md mirror `content/` sub-directories.
- **Link hygiene:** flag duplicates, dead links, or off-topic entries.
- **README improvements:** tables, navigation, section ordering.

## What Claude Should NOT Do

- Generate fake resource links or invent blog post URLs.
- Add resources that don't exist or aren't real, vetted external links.
- Refactor the repo structure without explicit instruction — the current layout is intentional.
