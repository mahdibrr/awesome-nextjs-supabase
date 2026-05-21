# Community Launch Plan

This launch should feel useful, not promotional. The strongest angle is:

> The production bugs the official docs skip.

Lead with the Production Incident Index, because it is the clearest differentiator from a generic resource list.

## Positioning

Use this short description across platforms:

> A production-focused Next.js + Supabase resource hub with a symptom-first incident index for Auth, RLS, middleware, caching, Stripe, deployment, and Realtime failures.

Avoid:

- "Please star my repo."
- "Ultimate resource."
- "Best list."
- Traffic, SEO, or personal-blog framing.

Use:

- "I made this because these bugs kept showing up in real apps."
- "The repo is meant to be useful without leaving GitHub."
- "Feedback and missing incidents are welcome."

## Launch Sequence

1. Soft launch to a small group of Next.js/Supabase builders.
2. Fix obvious feedback: broken links, unclear wording, missing incidents.
3. Post in focused Discord communities.
4. Post on Twitter/X and LinkedIn.
5. Publish a Dev.to article explaining the Production Incident Index.
6. Share on Reddit only after the repo has a few visible improvements from feedback.
7. Submit to awesome-list directories after the repo has community signals and stable formatting.

## Reddit Strategy

Best-fit communities:

- `r/nextjs`
- `r/Supabase`
- `r/webdev`
- `r/SaaS`
- `r/javascript`

Approach:

- Post only where self-promotion rules allow it.
- Lead with a real production problem, not the repo.
- Ask for missing incidents and corrections.
- Mention that the Production Incident Index is the main value.
- Avoid cross-posting everywhere on the same day.

Good title patterns:

- "I made a Production Incident Index for Next.js + Supabase bugs"
- "Common Next.js + Supabase production failures and how to debug them"
- "A symptom-first reference for Supabase Auth, RLS, middleware, and Stripe issues"

## Discord Strategy

Best-fit channels:

- Supabase community help/showcase channels
- Next.js community help/showcase channels
- Indie hacker and SaaS builder servers
- Full-stack TypeScript servers

Approach:

- Keep the message short.
- Ask for feedback on missing incidents.
- Link to the incident index rather than the homepage when allowed.
- Do not repost repeatedly.

Follow-up prompt:

> What production failure should be added next: Auth, RLS, Stripe, Realtime, caching, or deployment?

## LinkedIn Positioning

LinkedIn should focus on practical engineering lessons:

- Most SaaS bugs appear after the tutorial ends.
- Production readiness is a separate skill from building a demo.
- The incident index maps symptoms to root causes and verification steps.

Best format:

- Short story.
- Three examples.
- Link to repo.
- Ask for missing incidents.

## Twitter/X Thread Ideas

Thread angle:

> 7 Next.js + Supabase bugs that usually show up after deployment.

Suggested structure:

1. Hook: "The demo works. Production does not."
2. Auth session lost after refresh.
3. Supabase returns empty array.
4. Middleware redirect loop.
5. Stale App Router data.
6. Stripe webhook mismatch.
7. Realtime works for admins only.
8. Link to Production Incident Index.
9. Ask for missing cases.

## Dev.to Article Ideas

Best title:

> The Production Bugs the Official Docs Skip: Next.js + Supabase Incident Notes

Outline:

1. Why production bugs are different from tutorial bugs.
2. What a symptom-first incident index is.
3. Five examples from the repo.
4. How to use the checklist before shipping.
5. How to contribute missing incidents.

## Awesome-List Submission Prep

Before submitting:

- Verify the `awesome` and `awesome-list` topics are present.
- Confirm `awesome-lint README.md` passes.
- Confirm no duplicate README links.
- Confirm the README is neutral and not a personal blog funnel.
- Confirm contribution guidance is clear.
- Confirm the repo has enough external, official, and community resources.
- Add a pinned issue inviting resource and incident suggestions.

## Launch Metrics To Watch

Track these qualitatively, not obsessively:

- Are people saving/bookmarking the repo?
- Are comments suggesting real incidents?
- Are people saying "this happened to me"?
- Are maintainers or experienced builders correcting details?
- Are stars coming from useful shares rather than broad spam?
