# Debugging Playbook

Use this playbook when a Next.js + Supabase app works locally but breaks in preview, production, or authenticated flows.

## Supabase Auth Redirect Issues

Common symptoms:

- OAuth returns to the wrong URL.
- Magic links work locally but fail in production.
- User is logged in but redirected back to login.
- Callback route receives a code but no session is created.

Check:

- Supabase Dashboard -> Authentication -> URL Configuration.
- Site URL is the production domain.
- Redirect allowlist includes local, preview, and production callback URLs.
- The callback route exchanges the code for a session.
- Middleware is not redirecting the callback route before the session is set.
- Browser cookies are present after the callback completes.

Useful resources:

- [Supabase Auth Redirect Not Working in Next.js App Router](https://www.iloveblogs.blog/post/supabase-auth-redirect-fix)
- [Supabase + Google OAuth on Next.js 15](https://www.iloveblogs.blog/guides/supabase-google-oauth-nextjs-15-complete-guide)

## RLS Errors

Common symptoms:

- Queries return empty arrays instead of errors.
- Insert works with service role but fails for real users.
- Updates silently affect zero rows.
- Admin screens cannot read data after RLS is enabled.

Check:

- RLS is enabled intentionally.
- Policies exist for the exact operation: select, insert, update, delete.
- `using` and `with check` are both correct where needed.
- `auth.uid()` matches the row ownership column.
- Team access checks the membership table correctly.
- Policy columns are indexed.
- You are not testing with the service role key by accident.

Useful resources:

- [Why Your Supabase RLS Policies Are Silently Failing](https://www.iloveblogs.blog/post/supabase-rls-silent-failures-debug)
- [Debugging Supabase RLS Issues](https://www.iloveblogs.blog/post/debugging-supabase-rls-issues)

## Next.js Hydration Errors

Common symptoms:

- `Text content does not match server-rendered HTML`.
- Components flicker after page load.
- Auth-dependent UI renders differently on server and client.
- Dates, random values, or browser-only values cause mismatches.

Check:

- Avoid `Date.now()`, `Math.random()`, and browser APIs during server render.
- Move browser-only logic into `useEffect`.
- Render stable placeholders until client-only state is ready.
- Do not render different auth UI on server and client without a stable loading state.
- Validate HTML nesting.

Useful resource:

- [Next.js Hydration Mismatch Error](https://www.iloveblogs.blog/post/nextjs-hydration-mismatch-fix)

## API Connection Issues

Common symptoms:

- Supabase requests fail only on Vercel.
- API routes work locally but time out in production.
- Database connections spike under traffic.
- Environment variables are undefined during build or runtime.

Check:

- `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are set in the deployment platform.
- Server-only secrets do not use the `NEXT_PUBLIC_` prefix.
- Connection pooling is configured for serverless environments.
- Route handlers do not create unnecessary long-lived connections.
- Supabase project is not paused.
- CORS and allowed redirect URLs match the deployed domain.

Useful resources:

- [Supabase Connection Pooling with PgBouncer on Vercel](https://www.iloveblogs.blog/guides/supabase-connection-pooling-vercel)
- [Deploy Next.js 15 to Vercel Without Environment Variable Errors](https://www.iloveblogs.blog/post/nextjs-vercel-env-variables-fix)

## General Debugging Order

1. Reproduce the issue locally with production-like environment variables.
2. Check browser console and network tab.
3. Check Vercel function logs or deployment logs.
4. Check Supabase Auth logs and database logs.
5. Confirm whether the failing request uses anon, authenticated, or service role access.
6. Test the underlying SQL in Supabase SQL editor with an equivalent role.
7. Add one small fix, redeploy, and verify the original failing path.
