# Intermediate Layer

This directory contains **intermediate dbt models** — reusable transformation logic that sits between the staging and marts layers.

## Purpose

The intermediate layer exists to **abstract shared business logic** away from individual mart models. Any transformation that is:

1. **Used by more than one mart** (e.g. two different fact tables both need the same join or aggregation), or
2. **Computationally heavy** (e.g. window functions over large tables, complex unnesting),

...should be extracted from the mart model and placed here as a named intermediate model. This keeps mart models clean, avoids logic duplication, and makes the shared logic easier to test and maintain independently.

## Materialization Strategy

| Scenario | Recommended Materialization |
|---|---|
| Reused logic, lightweight | `ephemeral` (default) — compiled inline, no table overhead |
| Reused logic, heavy / slow | `table` — materializes once, reused by downstream models without recomputing |

The project-wide default in `dbt_project.yml` is set to `ephemeral` for this layer:
```yaml
intermediate:
  +materialized: ephemeral
```

Override to `table` at the model level using `{{ config(materialized='table') }}` when the CTE is expensive enough to warrant it.

## Naming Convention

Intermediate models follow the `int_<entity>_<transformation>.sql` naming pattern, e.g.:
- `int_crm_deal_stage_transitions.sql`
- `int_crm_activity_enriched.sql`

## Current State

No intermediate models are needed at this time — the business logic for the current marts is straightforward enough to flow directly from the staging layer. As the project grows and marts start sharing logic, models will be added here.
