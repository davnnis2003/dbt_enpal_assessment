# Seeds Layer Guidelines

This guide outlines our standards and design principles for the **Seeds Layer** (`seeds/`), following the official **[dbt Labs Best Practice Guide on Seeds](https://docs.getdbt.com/docs/build/seeds)**.

For a broader architectural overview of the project, please refer back to the [Main Project README](../README.md).

---

## 1. What are Seeds?
Seeds are CSV files in your dbt project (typically located in the `seeds/` directory) that dbt can load into your data warehouse using the `dbt seed` command. 

### Best Use Cases
Seeds are best suited for static, slow-changing, and small datasets.
- **Good seeds**: Country codes, static category mappings, lists of internal employee IDs.
- **Bad seeds**: Raw transactional tables, logs, or any large database tables that change frequently and exceed a few megabytes.

---

## 2. Ingested Datasets

This project ingests several Pipedrive CRM static data snapshots using dbt seeds:
- `activity_types.csv`
- `activity.csv`
- `deal_changes.csv`
- `fields.csv`
- `stages.csv`
- `users.csv`

---

## 3. Core Configurations

### Dedicated Source Schema
In accordance with our database design rules, seeds are configured to load into a dedicated schema named exactly `s_pipedrive` (instead of our default target schema). This is declared in `dbt_project.yml`:

```yaml
seeds:
  dbt_enpal_assessment:
    +schema: s_pipedrive
```
This isolates the raw CSV inputs in their own schema namespace before the staging models reference them.
