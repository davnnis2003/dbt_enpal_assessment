{{ config(
    materialized='table',
    schema='reporting',
    alias='rep_sales_funnel_monthly'
) }}

-- NOTE: Dense vs. Sparse Reporting Table
-- The current implementation produces a "sparse" table: only month × funnel_step combinations
-- that have at least one deal are present. Months with no activity for a given step will be
-- absent entirely, which can cause issues in dashboards that rely on a complete grid
-- (e.g. bar/line charts expecting every funnel step to appear for every month).
--
-- If a "dense" backbone is needed, restructure this model as follows:
--   1. Build a CTE `all_months` using GENERATE_SERIES over the full date range.
--   2. Build a CTE `all_funnel_steps` as a static VALUES list of all 11 funnel steps.
--   3. CROSS JOIN `all_months` × `all_funnel_steps` to produce every possible combination.
--   4. LEFT JOIN the actual aggregated deals_count onto that backbone.
--   5. Use COALESCE(deals_count, 0) so missing combinations default to 0 instead of NULL.

WITH
    stage_entries AS (
        SELECT
            CAST(DATE_TRUNC('month', mart__fct_crm_deal_changes.changed_at_berlin) AS DATE) AS month,
            mart__fct_crm_deal_changes.deal_id AS deal_id,
            CAST(mart__fct_crm_deal_changes.new_stage_id AS VARCHAR) AS funnel_step,
            mart__fct_crm_deal_changes.new_stage_name AS kpi_name
        FROM
            {{ ref('mart__fct_crm_deal_changes') }} AS mart__fct_crm_deal_changes
        WHERE
            mart__fct_crm_deal_changes.changed_field_key = 'stage_id'
            AND mart__fct_crm_deal_changes.new_stage_id IS NOT NULL
    ),
    activity_entries AS (
        SELECT
            CAST(DATE_TRUNC('month', mart__fct_crm_activities.due_at_berlin) AS DATE) AS month,
            mart__fct_crm_activities.deal_id AS deal_id,
            CASE
                WHEN mart__fct_crm_activities.activity_type_id = 1 THEN '2.1'
                WHEN mart__fct_crm_activities.activity_type_id = 2 THEN '3.1'
            END AS funnel_step,
            mart__fct_crm_activities.activity_type_name AS kpi_name
        FROM
            {{ ref('mart__fct_crm_activities') }} AS mart__fct_crm_activities
        WHERE
            mart__fct_crm_activities.activity_type_id IN (1, 2)
            AND mart__fct_crm_activities.deal_id IS NOT NULL
    ),
    union_entries AS (
        SELECT
            stage_entries.month AS month,
            stage_entries.deal_id AS deal_id,
            stage_entries.funnel_step AS funnel_step,
            stage_entries.kpi_name AS kpi_name
        FROM
            stage_entries AS stage_entries
        UNION ALL
        SELECT
            activity_entries.month AS month,
            activity_entries.deal_id AS deal_id,
            activity_entries.funnel_step AS funnel_step,
            activity_entries.kpi_name AS kpi_name
        FROM
            activity_entries AS activity_entries
    )
SELECT
    union_entries.month AS month,
    union_entries.funnel_step AS funnel_step,
    union_entries.kpi_name AS kpi_name,
    COUNT(DISTINCT union_entries.deal_id) AS deals_count
FROM
    union_entries AS union_entries
GROUP BY
    union_entries.month,
    union_entries.funnel_step,
    union_entries.kpi_name
ORDER BY
    1,
    2
