# Stripe Webhook Retry & Idempotency State Machine

Last verified: 2026-07-19

Companion to [INC-016](../incident-index/README.md): the failure mode where a webhook handler returns `200 OK` on a single delivery but the business side effects never committed (or committed twice on retry). The state machine below is the one defined in [`../templates/stripe-webhook-idempotency-template.sql`](../templates/stripe-webhook-idempotency-template.sql) (`received -> processing -> processed | failed`, with `processing_attempts` and `last_attempt_at`) and exercised by Scenarios 1-4 of [`../playbooks/stripe-webhook-test-plan.md`](../playbooks/stripe-webhook-test-plan.md). Every state name and transition here is pinned to those two files; no extra states were invented.

## State machine

```mermaid
stateDiagram-v2
    [*] --> received : insert event.id (state='received')
    received --> processing : "claim (attempts+1, last_attempt_at=now())"
    received --> processing : "retry after crash (no prior claim)"
    processing --> processed : "side effects commit"
    processing --> failed : "side effect raises / rollback"
    failed --> processing : "retry claims (attempts+1)"
    processing --> processing : "lease expired → reclaim"
    processed --> [*]
    failed --> [*]

    note left of processing
      Lease: a `processing` row whose
      `last_attempt_at` is older than the
      worst-case handler runtime is
      reclaimable (treat as crashed).
    end note

    note right of failed
      Once processing_attempts passes
      the cap, stop reclaiming and alert.
      Recovery belongs to the
      reconciliation backfill
      (Test Plan Scenario 6),
      not to Stripe retries.
    end note

    note left of processed
      Return 200 only when state reaches
      `processed` on THIS delivery.
      Return non-2xx while `processing`
      or for unfinished work so Stripe
      retries. Returning 200 with
      side effects uncommitted is the
      INC-016 trap.
    end note
```

## Three deliveries against the same handler

```mermaid
sequenceDiagram
    autonumber
    participant Stripe
    participant Handler as Next.js Route Handler
    participant DB as Supabase (stripe_webhook_events)

    rect rgb(230, 245, 255)
        Note over Stripe,DB: Delivery 1 - happy path
        Stripe->>Handler: POST event (evt_A)
        Handler->>DB: INSERT (evt_A, state='received')
        Handler->>DB: UPDATE claim (state='processing', attempts=1, last_attempt_at=now())
        Handler->>DB: BEGIN tx → side effects → COMMIT
        Handler->>DB: UPDATE (state='processed', processed_at=now())
        Handler-->>Stripe: 200 OK
    end

    rect rgb(255, 245, 230)
        Note over Stripe,DB: Delivery 2 - duplicate while processing (the INC-016 trap avoided)
        Stripe->>Handler: POST event (evt_A) re-delivered
        Handler->>DB: SELECT state FOR UPDATE
        DB-->>Handler: state='processing' (someone else / prior delivery owns it)
        Note over Handler: do NOT run side effects concurrently
        Handler-->>Stripe: 500 (non-2xx) - force Stripe to retry
    end

    rect rgb(255, 230, 230)
        Note over Stripe,DB: Delivery 3 - timeout then reclaim via lease
        Stripe->>Handler: POST event (evt_B)
        Handler->>DB: INSERT (evt_B, state='received')
        Handler->>DB: UPDATE claim (state='processing', attempts=1, last_attempt_at=now())
        Note over Handler: side effects start... then process crashes (no rollback)
        Handler--xStripe: no response (timeout)
        Note over DB: row stuck at state='processing', last_attempt_at stale
        Stripe->>Handler: POST event (evt_B) retry
        Handler->>DB: SELECT state, last_attempt_at FOR UPDATE
        Note over Handler: lease expired (last_attempt_at older than handler runtime cap)
        Handler->>DB: UPDATE reclaim (state='processing', attempts=2, last_attempt_at=now())
        Handler->>DB: BEGIN tx → side effects (idempotent) → COMMIT
        Handler->>DB: UPDATE (state='processed', processed_at=now())
        Handler-->>Stripe: 200 OK
    end
```

## Notes

- The state machine has exactly four states (`received`, `processing`, `processed`, `failed`) — matching the `CHECK` constraint in the SQL template. No diagram-only states were added.
- The claim step guards concurrency: `WHERE state IN ('received', 'failed') ... RETURNING id`. If `RETURNING` is empty, the caller must not run side effects (Delivery 2 above).
- Lease reclaim is not a new state; it is the `processing -> processing` self-loop driven by `last_attempt_at`, not a schema change.
- Side-effect idempotency (unique on `(stripe_event_id, side_effect_name)`) lives in the business tables, not in `stripe_webhook_events` — see the SQL template's closing note. The diagram assumes those constraints exist; otherwise re-execution is not safe.