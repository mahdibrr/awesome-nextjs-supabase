# Server Actions Debugging Matrix for Next.js Production Systems

Last verified: 2026-05-24

| Symptom | Likely Cause | First Check | Fix Pattern |
| --- | --- | --- | --- |
| Action succeeds but UI stale | Wrong revalidation target | Compare mutation path and revalidated path/tag | Revalidate exact route/tag consumed by UI fetch |
| Action fails only in production | Runtime mismatch (Edge vs Node) | Check route segment runtime config | Pin runtime to Node.js for Node-only dependencies |
| Unauthorized in action after login | SSR cookie not refreshed | Validate server-side `auth.getUser()` | Repair cookie refresh and callback flow |
| Action times out | Long sync work in request path | Inspect runtime logs and duration | Move heavy work to queue/background function |
| Intermittent data conflicts | Missing transaction boundaries | Inspect concurrent writes | Use transaction and idempotency keys |

## Quick Command Set

```bash
curl -I https://your-domain.com/dashboard
curl -I https://your-domain.com/auth/callback
```

```ts
import { revalidatePath } from "next/cache";
await mutation();
revalidatePath("/dashboard");
```
