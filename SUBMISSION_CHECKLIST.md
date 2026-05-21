# Submission Checklist

Launch readiness checklist for public distribution and possible awesome-list submission.

## Repository Quality

- [x] README explains why the repository exists in the first viewport.
- [x] README clearly positions the project around production Next.js and Supabase failures.
- [x] Production Incident Index is prominent and easy to find.
- [x] Selection Criteria section explains resource quality expectations.
- [x] How Resources Are Chosen section explains curation order.
- [x] What This Repo Covers section defines scope.
- [x] Navigation is scannable: Start Here, Most Useful Sections, failure categories, resources, tools, and community.
- [x] Formatting is consistent with awesome-list conventions.
- [x] Tone is practical, neutral, and developer-first.
- [x] No Stats section, traffic framing, or SEO-oriented language.
- [x] No keyword stuffing or promotional copy.

## Awesome-List Readiness

- [x] Awesome badge is on the same line as the H1 title.
- [x] README follows a curated-resource format.
- [x] Contribution guidance exists in `CONTRIBUTING.md`.
- [x] Changelog exists and shows recent maintenance.
- [x] Duplicate README links checked.
- [x] Duplicate README headings checked.
- [x] `awesome-lint README.md` passes.
- [x] Repository includes the `awesome` and `awesome-list` topics.
- [ ] Before submitting to `sindresorhus/awesome`, re-read the latest contribution guidelines and compare the README against accepted lists.

## Link and Resource Quality

- [x] External resources include official docs, open-source examples, and production tools.
- [x] Resource set is not dominated by one domain.
- [x] Domain mix includes Supabase, Next.js, Vercel, Stripe, GitHub, Playwright, Sentry, shadcn/ui, Drizzle, Prisma, LogRocket, PostHog, and independent engineering blogs.
- [x] No broken README external links found during launch audit.
- [x] No broken internal Markdown links found during launch audit.
- [x] Weak/redundant links were reduced during the diversification pass.

## Contributor Signals

- [x] Contributor badge is visible.
- [x] Last commit badge is visible.
- [x] Link-check badge is visible.
- [x] Issue template exists for resource requests.
- [x] Pull request template exists.
- [x] Community guide exists.
- [x] Good first issue ideas are documented.
- [x] Resource request backlog exists.
- [x] Community section links to issues, pull requests, Supabase discussions, and Next.js discussions.
- [ ] Enable GitHub Discussions in repository settings before wider launch. Public metadata audit on 2026-05-21 showed Discussions disabled.
- [ ] Pin an issue using `pinned-issue-template.md` after launch.

## Social Preview

- [ ] Add or verify a GitHub social preview image in repository settings.
- [ ] Preview the repository card on Twitter/X, LinkedIn, Discord, and Slack before posting widely.
- [ ] Use the same core positioning everywhere: "The production bugs the official docs skip."
- [ ] Lead with usefulness, not stars.
- [ ] Link directly to the Production Incident Index when posting in debugging-heavy communities.

## Distribution Readiness

- [x] Reddit post draft exists.
- [x] Discord post draft exists.
- [x] Twitter/X thread draft exists.
- [x] LinkedIn post draft exists.
- [x] Dev.to article outline exists.
- [x] Launch sequencing exists in `community-launch-plan.md`.
- [ ] Wait for at least one early feedback round before submitting to larger directories.
- [ ] Track repeated feedback and convert good suggestions into issues.

## Final Pre-Launch Commands

Run these immediately before a public launch push or awesome-list submission:

```bash
npx awesome-lint README.md
git diff --check
```

Optional deeper checks:

```bash
# Check Markdown links with your preferred link checker.
# Verify repository topics and description in GitHub settings.
# Confirm GitHub Discussions and social preview are enabled.
```
