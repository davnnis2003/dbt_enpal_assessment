# Staging Layer Guidelines

This guide outlines our standards and design principles for the **Staging Layer** (`models/staging/`), following the official **[dbt Labs Best Practice Guide on Staging Models](https://docs.getdbt.com/guides/best-practices/how-we-structure/3-staging)**. 

The staging layer is the foundational entry point of our dbt pipeline, responsible for standardizing raw data before it gets transformed into business logic.

---

## 1. Core Principles

- **1:1 Mapping**: Every staging model must map to exactly one source table/seed. Do not join tables or aggregate data in this layer.
- **Light cleaning only**: Staging is reserved for:
  - Renaming columns for consistency (e.g. converting snake_case, renaming abbreviations).
  - Explicit type casting (e.g. converting strings to numbers or booleans).
  - Timezone conversion (standardizing all UTC timestamps to local operating timezones like `Europe/Berlin`).
- **No business logic**: Keep calculations, business rules, and filters out of this layer. Business logic belongs in the intermediate or marts layers.

---

## 2. Structure & Conventions

### Directory Layout
Configuration files are separated from model files to keep directories clean:
- **Models**: Placed directly under `models/staging/` (e.g., `s_pipedrive__stg_pipedrive_activities.sql`).
- **Configurations**: Placed in the centralized subdirectory `models/staging/configs/` (e.g., `s_pipedrive__stg_pipedrive_activities.yml`).

### Naming Convention
Staging models follow the pattern:
```
<schema_name>__stg_<source>_<entity>.sql
```
*Example:* `s_pipedrive__stg_pipedrive_users.sql`

---

## 3. Core Technical Decisions

### Dedicated Schema Configuration
All staging models are configured to build into a dedicated schema named exactly `staging` (instead of the default target schema suffixing). This is handled via a custom macro overriding `generate_schema_name` ([generate_schema_name.sql](../../macros/generate_schema_name.sql)).

### Quality Safeguards & Testing
To enforce data integrity at the ingestion gate, every staging model configuration must define tests on its primary key:
- **`unique`**: Enforces entity grain integrity.
- **`not_null`**: Ensures no broken records are passed downstream.
