# Exploratory Data Analysis (EDA) & Data Findings

This document outlines the exploratory analysis of the raw Pipedrive CRM data loaded into the local database, detailing the structure, key metrics, mapping logics, and data quality insights identified.

---

## 1. Source Data Profiles

Prior to modeling, a volume and boundary analysis was conducted on the raw tables ingested from the CSV files:

| Source File / Table | Primary Entity / Focus | Total Records | Date Range / Boundaries (Berlin) | Key Relationships |
|---|---|---|---|---|
| `deal_changes.csv` | Log of all changes to deal attributes | 15,406 | 2024-03-01 to 2024-09-30 | 1:N with Deals (constructed from events) |
| `activity.csv` | Events / Actions logged against deals | 4,579 | 2024-01-02 to 2024-10-31 | N:1 with Deals, N:1 with Users |
| `activity_types.csv` | Static lookup metadata for activity categories | 4 | N/A | 1:N with `activity.csv` |
| `stages.csv` | Static lookup metadata for CRM pipeline stages | 9 | N/A | 1:N with `deal_changes.csv` |
| `users.csv` | System users / CRM owners | 1,787 | 2023-01-20 to 2024-10-02 | 1:N with Deals & Activities |
| `fields.csv` | CRM system field configuration schemas | 4 | N/A | Defines `changed_field_key` in changes log; contains JSON column (`field_value_options`) |

---

## 2. Funnel Step & Stage Mapping Logic

A major objective was identifying how the events in `deal_changes` map to the 9 funnel steps requested in the reporting schema:

### Pipeline Stages (`stages.csv`)
The raw dataset contains 9 chronological sales stages which map cleanly 1-to-1 with the core funnel steps:

| Funnel Step | Stage ID | Stage Name (Resolved) | Event Action Trigger |
|---|---|---|---|
| **1** | `1` | Lead Generation | `changed_field_key = 'stage_id'` AND `new_value = '1'` |
| **2** | `2` | Qualified lead | `changed_field_key = 'stage_id'` AND `new_value = '2'` |
| **3** | `3` | Needs Assessment | `changed_field_key = 'stage_id'` AND `new_value = '3'` |
| **4** | `4` | Proposal/Quote Preparation | `changed_field_key = 'stage_id'` AND `new_value = '4'` |
| **5** | `5` | Negotiation | `changed_field_key = 'stage_id'` AND `new_value = '5'` |
| **6** | `6` | Closing | `changed_field_key = 'stage_id'` AND `new_value = '6'` |
| **7** | `7` | Implementation/Onboarding | `changed_field_key = 'stage_id'` AND `new_value = '7'` |
| **8** | `8` | Follow-up/Customer Success | `changed_field_key = 'stage_id'` AND `new_value = '8'` |
| **9** | `9` | Renewal/Expansion | `changed_field_key = 'stage_id'` AND `new_value = '9'` |

### Funnel Sub-Steps (Activities Mapping)
The reporting specification includes sub-steps **2.1 (Sales Call 1)** and **3.1 (Sales Call 2)**. These do not represent pipeline stage changes; rather, they represent specific activities completed on the deal:

1. **Identifying Activity Categories**: Profiling the raw `activity_types.csv` and `activity.csv` tables reveals 4 distinct activity types:
   - `id = 1`: **Sales Call 1** (category: `meeting`)
   - `id = 2`: **Sales Call 2** (category: `sc_2`)
   - `id = 3`: **Follow Up Call** (category: `follow_up`)
   - `id = 4`: **After Close Call** (category: `after_close_call`)

2. **Formulating the Sub-step Logic**: 
   - Deals entering **Step 2.1 (Sales Call 1)** are identified by tracking when an activity of type `1` occurs on a valid `deal_id`.
   - Deals entering **Step 3.1 (Sales Call 2)** are identified by tracking when an activity of type `2` occurs on a valid `deal_id`.
   - The timestamp is resolved to `due_at_berlin` to capture when the interaction took place.

---

## 3. Data Quality Findings & Deduplication

Several critical data quality anomalies were discovered and addressed during the exploratory stage:

### Duplicate Activities in Raw Ingestion
When profiling `activity.csv`, duplicate records sharing the same `activity_id` were detected. 
- **Cause**: Upstream systems or ingestion errors occasionally double-loaded activity rows.
- **Handling**: To preserve grain integrity (where one row in staging represents one unique activity), the staging model uses a window function:
  ```sql
  row_number() OVER (PARTITION BY activity_id ORDER BY due_to DESC) AS row_num
  ```
  We filter for `row_num = 1` to deduplicate, retaining the most recently scheduled due date.

### Null Deals in Activities
A small subset of activities in `activity.csv` have a null `deal_id` (representing general user tasks not linked to specific sales pipelines). 
- **Handling**: These are safely filtered out in downstream funnel reporting (`WHERE deal_id IS NOT NULL`) as they do not map to funnel traversal.

### Missing Event Sequences (Lead Creation)
The raw changes log `deal_changes.csv` records transitions. While transitions between stages are logged, new deals are created with a `changed_field_key = 'add_time'` event. 
- **Handling**: In the fact table `mart__fct_crm_deal_changes`, the deal's overall creation time is isolated via the `add_time` event row (`MIN(changed_at_utc)` grouped by `deal_id`) and joined back as a structured column `deal_created_at_utc`. This allows analysts to compare any subsequent event against the baseline lifetime of the deal.
