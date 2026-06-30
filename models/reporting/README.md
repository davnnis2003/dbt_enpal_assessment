# Reporting Layer Guidelines

This guide outlines our standards and design principles for the **Reporting Layer** (`models/reporting/`). 

The reporting layer is positioned downstream of our Marts layer and serves as the final presentation layer, aggregating metrics specifically formatted for BI dashboards, reporting tools, and final user presentation.

---

## 1. Core Principles

- **Downstream Aggregations**: Models in this layer should combine and aggregate data from marts to present metrics in business-oriented schemas (e.g. daily, monthly, or cohort intervals).
- **BI & Dashboard Optimized**: Optimized specifically for performance and rendering in visualization tools (e.g. avoiding null gaps, pre-sorting time series, and optimizing joins).
- **Materialization**: Typically materialized as **tables** or **views** depending on update frequency requirements.

---

## 2. Structure & Conventions

### Directory Layout
- **Models**: Placed directly under `models/reporting/` (e.g., `rep_sales_funnel_monthly.sql`).
- **Configurations**: Placed in the centralized subdirectory `models/reporting/configs/` (e.g., `models/reporting/configs/mart__rep_sales_funnel_monthly.yml`).

### Naming Convention
Reporting models follow the pattern:
```
rep_<report_name>_<grain>.sql
```
*Example:* `rep_sales_funnel_monthly.sql`

---

## 3. Core Technical Decisions

### Custom Schema Configuration
All reporting models are configured to build into a dedicated schema named exactly `reporting` (rather than appending a target suffix). This is configured in `dbt_project.yml`:

```yaml
models:
  dbt_enpal_assessment:
    reporting:
      +schema: reporting
```

### Monthly Funnel Report (`rep_sales_funnel_monthly`)
The core monthly funnel report implements several specific engineering patterns:
- **Funnel Step Aggregation**: Aggregates deal stage transitions and activity milestones (Sales Call 1 and Sales Call 2) into monthly intervals, mapped to the standard funnel steps.
- **Dense Grid Backbone Approach**: The model uses a cross-joined calendar month × funnel step backbone, coalescing empty steps to `deals_count = 0`. This guarantees complete time-series rendering on BI dashboards and prevents missing steps or dates in charts.
- **Quality Guardrails**: Utilizes tests from the `dbt_utils` package (declared in `packages.yml`) to enforce data consistency constraints (e.g. checking that `deals_count >= 0`).
