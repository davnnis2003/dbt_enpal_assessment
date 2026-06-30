# Intermediate Layer Guidelines

This guide outlines our standards and design principles for the **Intermediate Layer** (`models/intermediate/`), following the official **[dbt Labs Best Practice Guide on Intermediate Models](https://docs.getdbt.com/guides/best-practices/how-we-structure/4-intermediate)**.

The intermediate layer serves as a stepping stone between the Staging and Marts layers. It is used to modularize complex business logic, perform joins, and pre-aggregate data before assembling data marts.

---

## 1. Core Principles

- **Modular Transformations**: Used to isolate reusable transformations (e.g. complex joins, pivoting, filtering, or aggregations) that would otherwise be duplicated across multiple marts.
- **Internal Layer Only**: Intermediate models are built for other dbt models to reference. They are **not** meant to be queried directly by BI tools or end-users.
- **Materialization**: By default, intermediate models are materialized as **views** or **ephemeral** models to keep the database tidy, unless performance requirements mandate building them as tables.

---

## 2. Structure & Conventions

### Directory Layout
- **Models**: Placed directly under `models/intermediate/` (e.g. `int_crm_users_joined.sql`).
- **Configurations**: Centralized in config files within the directory (e.g. `models/intermediate/int_crm_users_joined.yml`).

### Naming Convention
Intermediate models follow the pattern:
```
int_<entity>_<verb_or_logic>.sql
```
*Example:* `int_crm_users_joined.sql`
