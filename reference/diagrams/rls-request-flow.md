# RLS Request Flow: Problem -> Fix -> Production Guide

```mermaid
flowchart TD
    A["Client request with JWT"] --> B["Next.js SSR route handler"]
    B --> C["Supabase query with user session"]
    C --> D["PostgreSQL evaluates RLS USING clause"]
    D --> E{"Row allowed?"}
    E -- Yes --> F["Result rows returned"]
    E -- No --> G["Empty array or permission error"]
    G --> H["Run RLS audit SQL and inspect policy predicates"]
```

## Verification Steps

1. Re-run the failing query with a real authenticated token.
2. Confirm policy predicates include tenant/user scope.
3. Run `EXPLAIN ANALYZE` for policy-heavy queries.
4. Validate no client code uses `service_role` credentials.
