# Metrify Case Study

This project implements the analytics engineering pipeline using DBT for Pipedrive CRM data.

## Getting Started

### 0. Prerequisites
- Install and run [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- Install `uv` (recommended) or `pip` on your machine.

### 1. Spin up Postgres
```bash
docker compose up -d
```
*Credentials: `localhost:5432` | User: `admin` | Password: `admin` | DB: `postgres`*

### 2. Setup Environment & Run DBT
Using `uv` (recommended):
```bash
uv venv && source .venv/bin/activate && uv pip install -r pyproject.toml
```
Or using `pip`:
```bash
pip install dbt-core dbt-postgres
```

Then run the pipeline:
```bash
dbt deps && dbt build
```

---

# Data Modeling Practices
This project adheres to modern analytics engineering standards by combining **[Dimensional Modeling](https://en.wikipedia.org/wiki/Dimensional_modeling)** principles (Kimball methodology adapted for modern cloud data warehouses) with the official **[dbt Labs Best Practice Guide on project structure](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview)**. 

Our practices focus on modularity, clear grain definition, schema separation, tool-agnostic interfaces in presentation layers, and incremental processing for performance.

## Folder Structures & Project Organization
We have structured the project models according to the dbt Labs directory guidelines:
- **Source Layer (`models/sources.yml`)**: Declares raw connection namespaces for external database tables. *(Note: Not utilized in this project as raw inputs are static CSVs loaded via the Seed layer).*
- **Seed Layer (`seeds/`)**: Manages the ingestion of small, static lookup datasets directly from version-controlled CSV files. See the [Seeds Layer Guide](seeds/README.md) for details on static inputs and configurations.
- **Staging Layer (`models/staging/`)**: Contains models that have direct 1:1 relationships with our raw source tables. They perform light cleaning, renaming, casting, and timezone conversion. See the [Staging Architecture Guide](models/staging/README.md) for details on naming conventions, directory layout, and configurations.
- **Intermediate Layer (`models/intermediate/`)**: Contains models representing reusable business logic transformations. See the [Intermediate Architecture Guide](models/intermediate/README.md) for details on modular logic boundaries.
- **Marts Layer (`models/marts/`)**: Contains the business-ready presentation models. See the [Marts Architecture Guide](models/marts/README.md) for details on our design principles and mart classifications:
  - **Dimension Tables (`dim_`)**: Descriptive entities (e.g. `dim_crm_users`).
  - **Fact Tables (`fct_`)**: Action/event-based metrics (e.g. `fct_crm_activities`).
- **Reporting Layer (`models/reporting/`)**: Dedicated presentation layer positioned downstream of the Marts layer, aggregating metrics specifically for BI dashboards and final reporting (e.g. `rep_sales_funnel_monthly`).

---

## Project Architecture & Core Decisions

### 1. Schema Configurations
- Staging models are configured to build into a dedicated schema named exactly `staging` (instead of appending a target prefix). This is accomplished via a custom macro overriding `generate_schema_name` ([generate_schema_name.sql](file:///Users/jimmypang/AntigravityProjects/dbt_enpal_assessment/macros/generate_schema_name.sql)).

### 3. DBT Seeds
- **dbt Seeds**: We use [dbt seeds](https://docs.getdbt.com/docs/build/seeds) to load and manage the CSV data files (`activity_types.csv`, `activity.csv`, `deal_changes.csv`, `fields.csv`, `stages.csv`, and `users.csv`) located under `seeds/` (copied from `raw_data/`).
- **Dedicated Schema**: These seeds are configured in `dbt_project.yml` to build into a dedicated schema named exactly `s_pipedrive`.

### 4. Tests on Primary Keys
- Every staging model configures data validation tests on its primary key (e.g., `unique` and `not_null` constraints on `activity_type_id` and `field_id`) in its respective YML configuration file to guarantee data integrity at the entry point of the pipeline.

### 5. DBT Documentation
- Table and column descriptions are documented in the model YAML files. You can generate and view the interactive documentation site using:
  ```bash
  dbt docs generate
  dbt docs serve
  ```

### 6. Gitignoring the `target/` Directory (Considerations)
- We considered adding the `target/` folder to `.gitignore` since committing artifacts of every dbt invocation (such as compiled SQL, manifest files, and run results) is not useful and adds unnecessary noise to the repository.
- However, we chose to keep it in git tracking for **interview purposes only** to make it easy to inspect generated files without requiring local database runs. In a production environment, we would absolutely ignore `target/` unless a very clear use case exists.

### 7. Timezone Handling
- **Timezone Conversion**: Metrify currently operates exclusively in the Germany market and the team is located in Berlin. Source data from Pipedrive is provided in UTC by default. To align analytics and reports with local operations, all UTC timestamps are converted to the `Europe/Berlin` timezone in the staging layer models (e.g. `due_at` in [stg_pipedrive_activities.sql](file:///Users/jimmypang/AntigravityProjects/dbt_enpal_assessment/models/staging/stg_pipedrive_activities.sql)).

### 8. PII & GDPR Compliance
- **GDPR Policy**: The staging users model (`stg_pipedrive_users`) ingests PII columns (`user_name`, `email`) directly from raw sources to capture the full source schema.
- **Internal Employees Assumption**: All users are assumed to be Metrify internal employees. Therefore, PII (name and email) is kept directly in the main dimension table (`dim_crm_users`) without a separate restricted PII schema or access request process.
- **Data Retention Policy**: To comply with GDPR guidelines, user data in `dim_crm_users` is proposed to be excluded or deleted if it is older than 6 months (based on `modified_at_utc`). The exact details of this mechanism must be aligned with the Data Protection Officer (DPO), specifically:
  - Confirming the exact retention window (6 months vs. other regulatory periods).
  - Deciding between physical deletion (hard/soft delete in the database) vs. logical filtering at query/view level.
  - Ensuring upstream/downstream impact analysis is done for historical tracking and reporting purposes.

### 9. JSON Unnesting (CRM Fields)
- **JSON Options Unnesting**: Staged CRM field definitions include a JSON column `field_value_options` containing an array of key-value pairs (id and label options). To hide the complexity of JSON arrays from business stakeholders and ensure query performance at scale, we unnested these values into a dedicated `dim_crm_field_options` table (configured as a separate dimension in the marts layer). The raw JSON column is excluded from the main `dim_crm_fields` dimension table.

### 10. Incremental Materialization Strategy
- **Incremental Materialization**: The heavy marts fact tables (`mart__fct_crm_activities` and `mart__fct_crm_deal_changes`) are materialized as `incremental` to optimize query performance and reduce processing costs.
- **Schema Evolution Policy**:
  - The project-wide default is configured in `dbt_project.yml` as `+on_schema_change: "append_new_columns"`. This default is chosen because automatically syncing column removals or renames in production is risky; it should remain a manual, intentional action. Silent column drops or renames can easily break downstream dependencies, such as reporting dashboards, BI tools, or other dependent dbt models.
  - The two marts fact tables override this with `on_schema_change='sync_all_columns'` to automatically handle added, renamed, or deleted columns.
- **Reusable Filtering Macro**: Created the `get_incremental_date_filter` macro ([get_incremental_date_filter.sql](file:///Users/jimmypang/AntigravityProjects/dbt_enpal_assessment/macros/get_incremental_date_filter.sql)) to safely handle postgres timestamp/date filtering within subqueries to avoid aggregate/correlation errors.
- **Upstream Performance Filtering**:
  - In `mart__fct_crm_activities.sql`, we filter records early within the `activities` CTE before joining to `activity_types`.
  - In `mart__fct_crm_deal_changes.sql`, we compute the `LAG()` function over the full history in `deal_changes_raw` (retaining window calculation correctness), and then apply the incremental filter directly in the `deal_changes` CTE. This ensures downstream joins are only processed for the new incremental rows.

### 11. CI/CD Best Practices
To ensure pipeline stability and catch issues before they reach production:
- **`dbt compile` Checks**: The CI pipeline should run `dbt compile` on every Pull Request to verify syntax correctness, project configuration compliance, and macro resolutions.
- **Dry-Run in Ephemeral Database/Schema**: Before merging to production, the CI pipeline should run the modified dbt models against an ephemeral/temporary schema or database (or cloned environment) to perform a full dry-run execution. This verifies that all queries execute successfully against the database engine.

### 12. Reporting Layer & Monthly Funnel Report
- **Reporting Schema**: Configured a dedicated custom schema `reporting` using dbt custom schemas mapping to separate reporting models.
- **Monthly Funnel Report (`rep_sales_funnel_monthly`)**: Directly aggregates stage transition events and key activities (Sales Call 1 and Sales Call 2) into monthly intervals, mapping them to the requested funnel steps (`1`, `2`, `2.1`, `3`, `3.1`, `4`, `5`, `6`, `7`, `8`, `9`), and computes the exact count of unique deals that entered each step.
- **Dense Reporting Table (Backbone Approach)**: The model uses a `CROSS JOIN` backbone of all observed calendar months × all 11 funnel steps to guarantee a complete grid in the output. Steps with no deals in a given month emit `deals_count = 0` via `COALESCE`, making the table safe for dashboards relying on full month × funnel_step coverage (e.g. time-series charts).
- **dbt Packages (`dbt_utils`)**: Added `dbt-labs/dbt_utils` (declared in [packages.yml](packages.yml), installed via `dbt deps`). Currently used for the `dbt_utils.expression_is_true` test enforcing `deals_count >= 0` on `rep_sales_funnel_monthly`. Additional tests (e.g. `unique_combination_of_columns`) and macros can be adopted incrementally as needed.

### 13. dbt Exposures (Downstream Lineage)
- **Purpose**: dbt Exposures declare downstream consumers of dbt models to complete the DAG lineage beyond dbt itself. This enables `dbt docs` to surface end-to-end data lineage — from raw sources all the way to the final consumer — and makes impact analysis possible (e.g. "which dashboards are affected if I change `fct_crm_deal_changes`?").
- **Placement**: Exposures are defined in a dedicated [exposures.yml](file:///Users/jimmypang/AntigravityProjects/dbt_enpal_assessment/models/exposures.yml) at the `models/` root level (rather than inside a specific layer folder) since downstream consumers can depend on models from any layer — not just reporting.
- **Current Exposure** (`sales_funnel_monthly_dashboard`): Declares the monthly sales funnel dashboard as a consumer of `rep_sales_funnel_monthly`.
- **Future Exposures** can be added to represent other downstream dependencies, for example:
  - **BI / Dashboards**: Metabase, Looker, Tableau reports consuming marts or reporting models.
  - **Reverse ETL**: Tools like Census or HubSpot/Salesforce syncs consuming mart-level aggregates.
  - **ML / Feature Stores**: Algorithms consuming mart-level aggregates as training features.

---

## Original Assignment Specification

### Funnel Steps (KPIs)
- **Step 1**: Lead Generation
- **Step 2**: Qualified Lead
  - **Step 2.1**: Sales Call 1
- **Step 3**: Needs Assessment
  - **Step 3.1**: Sales Call 2
- **Step 4**: Proposal/Quote Preparation
- **Step 5**: Negotiation
- **Step 6**: Closing
- **Step 7**: Implementation/Onboarding
- **Step 8**: Follow-up/Customer Success
- **Step 9**: Renewal/Expansion

### Reporting Model Schema
- `month`
- `kpi_name`
- `funnel_step`
- `deals_count`
