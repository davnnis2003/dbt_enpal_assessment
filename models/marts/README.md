# Understanding Data Marts in Modern Analytics Engineering

This guide outlines our standards and strategic framework for the **Marts Layer** (`models/marts/`), heavily inspired by the principles discussed in the article:
👉 **[Data Marts in 2025: A dbt-First Guide for Analytics Engineering](https://jimmypang.substack.com/p/understanding-data-marts-in-modern)** by Jimmy Pang.

---

## 1. What is a Data Mart?
In modern cloud data warehousing, the Marts layer represents the **business-ready presentation layer**. Unlike staging models (which map 1:1 to raw sources) and intermediate models (which handle modular transformation steps), data marts are built to be consumed directly by BI tools, dashboards, reverse ETL syncs, and business stakeholders.

Rather than sticking to strict, highly-normalized traditional Kimball star schemas (designed when compute and storage were expensive), modern data marts prioritize **wide, denormalized, and business-focused structures** that optimize query speed and user comprehension.

---

## 2. Five Types of Data Marts
According to modern dbt architecture best practices, models in our Marts layer fall into five distinct categories:

1. **Dimension Tables (`dim_`)**
   - Contain descriptive context about a business entity (e.g. users, CRM stages, field options).
   - Serves as the primary source of attributes for filtering, grouping, and slicing.
2. **Fact Tables (`fct_`)**
   - Contain quantitative, transactional, or event-based measurements (e.g. activities, deal stage changes).
   - Typically represent the main business processes and are often configured with incremental materialization.
3. **Summary / Aggregation Tables (`sum_`)**
   - Pre-aggregated metrics or pre-joined datasets designed to optimize dashboard performance (e.g. monthly sales funnel metrics).
4. **Snapshots (`snp_`)**
   - Capture point-in-time states of changing data over time (e.g. checking monthly or daily histories).
5. **Manual / Static Tables**
   - Hardcoded lookup tables or static seed mapping files loaded into the warehouse (e.g. CRM field types).

---

## 3. Key Design Principles

### 🪙 Tool-Agnostic Naming
To insulate downstream reports from specific underlying source tools, models in the marts layer use **tool-agnostic** names. 
- *Instead of:* `dim_pipedrive_users`
- *Use:* `dim_crm_users`
This ensures that if the source tool ever changes (e.g. from Pipedrive to Salesforce), only the staging layer needs to be updated, leaving the marts interfaces intact.

### 🧩 Granularity (The "Grain")
Every data mart model must have a clearly defined and documented "grain" (the level of detail represented by a single row). Primary keys should be tested for uniqueness and nullability to guarantee the grain is never compromised by accidental duplication.

### 🛡️ Schema Evolution & Performance
- Mart tables should utilize **Incremental Materialization** for large, heavy-volume tables (like fact tables) to optimize compute resources.
- Use explicit schema change configurations (like `on_schema_change: append_new_columns` or `sync_all_columns`) to prevent breaking downstream applications during schema updates.
