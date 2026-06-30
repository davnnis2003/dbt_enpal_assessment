# DBT Pipedrive Analytics Project

This project implements the analytics engineering pipeline using DBT for Pipedrive CRM data.

## Project Structure & Architecture

### 1. Folder Structures & Project Organization
We have structured the project models according to the [dbt Labs Best Practice Guide on project structure](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview):
- **Staging Layer (`models/staging/`)**: Contains models that have direct 1:1 relationships with our raw source tables. They perform light cleaning, renaming, and casting.
  - Staging SQL models are named using the `stg_<source>_<entity>` convention (e.g., `stg_pipedrive_activity_types.sql`).
  - Staging configuration files are stored in a centralized `configs` subdirectory (`models/staging/configs/stg_pipedrive_activity_types.yml`) to keep configuration files separated from models.
- **Intermediate Layer (`models/intermediate/`)**: Will contain models representing reusable business logic transformations.
- **Marts Layer (`models/marts/`)**: Will contain the final presentation and dimension models (such as `rep_sales_funnel_monthly` or `dim_crm_users`).
  - Marts models use a **tool-agnostic naming convention** (e.g. `dim_crm_activity_types` instead of `dim_pipedrive_activity_types`). This abstracts downstream models from specific source tooling (Pipedrive) to represent business entities (like CRM) cleanly.
  - Marts configuration files are stored in a centralized `configs` subdirectory (e.g., `models/marts/configs/mart__dim_crm_activity_types.yml`) to keep configuration files separated from models.

### 2. Schema Configurations
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
- **Placement**: Exposures are defined in a dedicated [exposures.yml](../models/exposures.yml) at the `models/` root level (rather than inside a specific layer folder) since downstream consumers can depend on models from any layer — not just reporting.
- **Current Exposure** (`sales_funnel_monthly_dashboard`): Declares the monthly sales funnel dashboard as a consumer of `rep_sales_funnel_monthly`.
- **Future Exposures** can be added to represent other downstream dependencies, for example:
  - **BI / Dashboards**: Metabase, Looker, Tableau reports consuming marts or reporting models.
  - **Reverse ETL**: Tools like Census or Hightouch syncing enriched CRM data back to Salesforce/HubSpot.
  - **ML / Feature Stores**: Algorithms consuming mart-level aggregates as training features.

---

## Original Assignment Details

### Setup

1. Download Docker Desktop (if you don’t have installed) using the official website, install and launch.
2. Fork this Github project to you Github account. Clone the forked repo to your device.
3. Open your Command Prompt or Terminal, navigate to that folder, and run the command `docker compose up`.
4. Now you have launched a local Postgres database with the following credentials:
 ```
    Host: localhost
    User: admin
    Password: admin
    Port: 5432 
 ```
5. Connect to the db via a preferred tool (e.g. DataGrip, Dbeaver etc)
6. Install dbt-core and dbt-postgres using pip (if you don’t have) on your preferred environment.
7. Now you can run `dbt run` with the test model and check public_pipedrive_analytics schema to see the dbt result (with one test model)

### Project
1. Remove the test model once you make sure it works
2. Dive deep into the Pipedrive CRM source data to gain a thorough understanding of all its details. (You may also research the Pipedrive CRM tool terms).
3. Define DBT sources and build the necessary layers organizing the data flow for optimal relevance and maintainability.
4. Build a reporting model (rep_sales_funnel_monthly) with monthly intervals, incorporating the following funnel steps (KPIs):  
  &nbsp;&nbsp;&nbsp;Step 1: Lead Generation  
  &nbsp;&nbsp;&nbsp;Step 2: Qualified Lead  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 2.1: Sales Call 1  
  &nbsp;&nbsp;&nbsp;Step 3: Needs Assessment  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 3.1: Sales Call 2  
  &nbsp;&nbsp;&nbsp;Step 4: Proposal/Quote Preparation  
  &nbsp;&nbsp;&nbsp;Step 5: Negotiation  
  &nbsp;&nbsp;&nbsp;Step 6: Closing  
  &nbsp;&nbsp;&nbsp;Step 7: Implementation/Onboarding  
  &nbsp;&nbsp;&nbsp;Step 8: Follow-up/Customer Success  
  &nbsp;&nbsp;&nbsp;Step 9: Renewal/Expansion
5. Column names of the reporting model: `month`, `kpi_name`, `funnel_step`, `deals_count`
6. “Git commit” all the changes and create a PR to your forked repo (not the original one). Send your repo link to us.
