# Production Engineering Reference System for Next.js + Supabase

This directory contains reusable production assets for operating Next.js + Supabase systems.

## Structure

- `incident-index/` - Symptom-first production incident catalog.
- `checklists/` - Rollout and release safety checklists.
- `sql/` - Reusable SQL audits and policy validation scripts.
- `templates/` - Copy-ready production schema and integration templates.
- `playbooks/` - Operational recovery and debugging playbooks.
- `diagrams/` - Architecture and lifecycle diagrams for incident response.

## How To Use

1. Start with `incident-index/README.md` when you have an active failure.
2. Move to `checklists/` before deploy windows.
3. Use `sql/` and `templates/` during migrations and policy hardening.
4. Use `playbooks/` for rollback or post-incident procedures.
5. Use `diagrams/` when documenting architecture decisions.
