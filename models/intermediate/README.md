# Intermediate Layer Guidelines

This directory (`models/intermediate/`) is designated for intermediate models, which serve as modular stepping stones between the Staging and Marts layers. 

### Current Project Status
For this CRM analytics funnel project, all event construction, state tracking, and resolving calculations are modeled directly inside the core Dimension and Fact models in the `marts` layer (e.g., leveraging window functions and joins in `mart__fct_crm_deal_changes` and `mart__fct_crm_activities`). 

Consequently, no intermediate models (`int_`) are materialized in this layer. The directory is kept as part of the overall structure to ensure consistency with our standard dbt project organization and support future expansion (e.g. multi-step lead transitions, pipeline event tracking).

---

## Standard Design Principles
If added in the future, intermediate models should follow these guidelines:
- **Modular Transformations**: Used to isolate reusable transformations (e.g. complex joins, pivoting, filtering, or aggregations) that would otherwise be duplicated across multiple marts.
- **Internal Layer Only**: Intermediate models are built for other dbt models to reference. They are **not** meant to be queried directly by BI tools or end-users.
- **Materialization**: By default, intermediate models should be materialized as **views** or **ephemeral** models to keep the database tidy.
