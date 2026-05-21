# Good First Issues

Use this list to find small, useful contributions.

You do not need to rewrite the repository to help. The best first contributions are narrow and practical.

## Link Quality

- Check one section for broken or redirected links.
- Replace outdated docs with current official docs.
- Mark legacy resources clearly when they are still useful.
- Remove duplicate resources that do not add new value.

## Production Incident Additions

Add one missing incident to the Production Incident Index.

Good areas:

- RLS returns empty data.
- RLS update policies fail because `with check` is missing.
- Supabase Auth session disappears after refresh.
- OAuth callback works locally but fails in preview.
- Middleware redirect loop.
- Stripe webhook signature mismatch.
- App Router cache does not update after a mutation.
- Realtime subscription duplicates messages.

Suggested format:

```md
| Symptom                   | Root Cause    | Fix                          |
| ------------------------- | ------------- | ---------------------------- |
| Short production symptom. | Likely cause. | Practical fix and reference. |
```

## Resource Descriptions

Improve one description so it answers:

- What is this?
- Who is it for?
- What production problem does it help solve?

Before:

```md
- [Tool](https://example.com) - Useful tool.
```

After:

```md
- [Tool](https://example.com) - Monitors auth, billing, and checkout flows from outside the app.
```

## Help Wanted Areas

- RLS incidents and policy examples.
- Deployment failures on Vercel and preview environments.
- Maintained SaaS starter kits.
- Monitoring and tracing tools.
- Supabase Auth edge cases.
- Stripe billing and webhook reliability.
- Realtime authorization and cleanup issues.

## First Pull Request Checklist

- Keep the change focused.
- Use neutral wording.
- Add official docs when possible.
- Avoid duplicate links.
- Run `npx awesome-lint README.md` if you edit the README.
- Explain the production value in the pull request.
