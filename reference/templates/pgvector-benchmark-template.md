# pgvector Benchmark Template for Supabase RAG Production Evaluation

Last verified: 2026-05-24

## Goal

Measure query latency, retrieval quality, and index health before and after schema/model changes.

## Benchmark Inputs

- Embedding model and vector dimension
- Corpus size (document count and token size)
- Filter predicates (tenant, visibility, language)
- Top-k setting and similarity metric

## Metrics

| Metric | Baseline | Candidate | Notes |
| --- | --- | --- | --- |
| P50 latency (ms) |  |  |  |
| P95 latency (ms) |  |  |  |
| P99 latency (ms) |  |  |  |
| Recall@k |  |  |  |
| Failed queries |  |  |  |
| CPU load |  |  |  |

## Query Template

```sql
-- Replace with your table/index names and embedding literal.
explain analyze
select id, content
from public.documents
where tenant_id = 'replace-tenant-id'
order by embedding <-> '[0.0,0.0,0.0]'::vector
limit 10;
```

## Release Decision

- Do not ship if P95 latency regresses above agreed threshold.
- Do not ship if recall drops below agreed quality threshold.
- Record model version and index strategy in release notes.
