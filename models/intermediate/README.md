# Intermediate Layer

This directory contains **intermediate dbt models** — an **optional supporting layer** for the marts layer, not a mandatory part of every dbt project.

## Purpose

The intermediate layer is a convenience layer used to **abstract shared or heavy business logic** out of individual mart models. Models should only be promoted here when there is a clear practical reason — most commonly:

1. **Shared across more than one mart** (e.g. two different fact tables both need the same join or complex aggregation) — avoiding copy-paste logic duplication.
2. **Computationally heavy** (e.g. expensive window functions over large tables, multi-step unnesting) — materializing once so downstream marts don't each re-run the expensive computation.

If neither of these conditions applies, logic belongs directly in the mart model as a CTE. The intermediate layer should never be created just for the sake of having it.

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
