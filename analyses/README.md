# DBT Analyses

This directory contains ad-hoc SQL queries and analytical scratchpads. Unlike models inside the `models/` directory, files in `analyses/` are compiled by dbt but are **not** materialized as tables or views in your database. 

They are useful for ad-hoc investigations, volume analysis, and debugging.

## How to Run Analyses

You can compile or preview the analyses using the following commands:

### 1. Compile the Analysis SQL
To compile the Jinja templates (like `{{ ref(...) }}`) into raw SQL:
```bash
uv run dbt compile --select <analysis_name>
```
The compiled output will be generated under `target/compiled/enpal_assessment_project/analyses/<analysis_name>.sql`.

### 2. Preview Results
To execute the query and view the results in the terminal:
```bash
uv run dbt show --select <analysis_name>
```

---

## Available Analyses

### 1. Changed Field Keys Distribution
- **File**: [deal_changes_field_keys.sql](../analyses/deal_changes_field_keys.sql)
- **Goal**: Find the unique values and total volume of changed fields within the staging deal changes data.
- **Run**:
  ```bash
  uv run dbt show --select deal_changes_field_keys
  ```

### 2. Deal Changes Timeline by Deal ID
- **File**: [deal_changes_by_deal.sql](../analyses/deal_changes_by_deal.sql)
- **Goal**: Query the chronological history of changes (e.g., stage movements, owner changes, lost reasons) for a specific deal (defaulting to Deal ID `155164`).
- **Run**:
  ```bash
  uv run dbt show --select deal_changes_by_deal
  ```

---

## Coding Conventions
All analyses must follow the project-wide engineering guidelines:
- **SQL Capitalization**: All SQL reserved words, functions, and operators (e.g., `SELECT`, `FROM`, `WHERE`, `JOIN`, `AS`, `ORDER BY`, `GROUP BY`) must be capitalized.
- **SQL Aliasing**: Always use explicit `AS` aliases for all columns and tables in SQL statements, even when the column name is unchanged. Do not use abbreviated aliases.
