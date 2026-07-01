

-- NOTE: Dense Reporting Table (Backbone Approach)
-- This model uses a CROSS JOIN backbone of all months × all funnel steps to ensure every
-- combination appears in the output, even if no deals were recorded for that step that month.
-- Missing combinations default to deals_count = 0 via COALESCE, making this safe for dashboards
-- that expect a complete grid (e.g. time-series bar/line charts).

WITH
    stage_entries AS (
        SELECT
            CAST(DATE_TRUNC('month', mart__fct_crm_deal_changes.changed_at_berlin) AS DATE) AS month,
            mart__fct_crm_deal_changes.deal_id AS deal_id,
            CAST(mart__fct_crm_deal_changes.new_stage_id AS VARCHAR) AS funnel_step,
            mart__fct_crm_deal_changes.new_stage_name AS kpi_name
        FROM
            "postgres"."marts"."fct_crm_deal_changes" AS mart__fct_crm_deal_changes
        WHERE
            mart__fct_crm_deal_changes.changed_field_key = 'stage_id'
            AND mart__fct_crm_deal_changes.new_stage_id IS NOT NULL
    ),
    activity_entries AS (
        SELECT
            CAST(DATE_TRUNC('month', mart__fct_crm_activities.due_at_berlin) AS DATE) AS month,
            mart__fct_crm_activities.deal_id AS deal_id,
            -- NOTE: Mapping specific activity types to funnel sub-steps as identified during EDA:
            -- activity_type_id = 1 maps to category 'meeting' ("Sales Call 1") -> Funnel Step '2.1'
            -- activity_type_id = 2 maps to category 'sc_2' ("Sales Call 2") -> Funnel Step '3.1'
            CASE
                WHEN mart__fct_crm_activities.activity_type_id = 1 THEN '2.1'
                WHEN mart__fct_crm_activities.activity_type_id = 2 THEN '3.1'
            END AS funnel_step,
            mart__fct_crm_activities.activity_type_name AS kpi_name
        FROM
            "postgres"."marts"."fct_crm_activities" AS mart__fct_crm_activities
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
    ),
    -- Generate one row per calendar month across the full observed date range
    -- NOTE: GENERATE_SERIES is Postgres-specific. In cloud data warehouses, use target equivalents:
    -- e.g. BigQuery: UNNEST(GENERATE_DATE_ARRAY(...))
    -- e.g. Snowflake: generator tables or recursive CTEs
    -- Alternatively, the cross-database `dbt_utils.date_spine` macro can be used to generate this sequence database-agnostically.
    all_months AS (
        SELECT
            CAST(DATE_TRUNC('month', generate_series.month_start) AS DATE) AS month
        FROM
            GENERATE_SERIES(
                (SELECT MIN(DATE_TRUNC('month', stage_entries.month)) FROM stage_entries AS stage_entries),
                (SELECT MAX(DATE_TRUNC('month', stage_entries.month)) FROM stage_entries AS stage_entries),
                INTERVAL '1 month'
            ) AS generate_series(month_start)
    ),
    -- Static list of all 11 known funnel steps and their display names
    all_funnel_steps AS (
        SELECT
            all_funnel_steps.funnel_step AS funnel_step,
            all_funnel_steps.kpi_name AS kpi_name
        FROM (
            VALUES
                ('1',   'Lead Generation'),
                ('2',   'Qualified lead'),
                ('2.1', 'Sales Call 1'),
                ('3',   'Needs Assessment'),
                ('3.1', 'Sales Call 2'),
                ('4',   'Proposal/Quote Preparation'),
                ('5',   'Negotiation'),
                ('6',   'Closing'),
                ('7',   'Implementation/Onboarding'),
                ('8',   'Follow-up/Customer Success'),
                ('9',   'Renewal/Expansion')
        ) AS all_funnel_steps(funnel_step, kpi_name)
    ),
    -- Backbone: every possible month × funnel_step combination
    backbone AS (
        SELECT
            all_months.month AS month,
            all_funnel_steps.funnel_step AS funnel_step,
            all_funnel_steps.kpi_name AS kpi_name
        FROM
            all_months AS all_months
        CROSS JOIN
            all_funnel_steps AS all_funnel_steps
    ),
    -- Actual aggregated counts from observed data
    aggregated AS (
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
    )
SELECT
    backbone.month AS month,
    backbone.funnel_step AS funnel_step,
    backbone.kpi_name AS kpi_name,
    COALESCE(aggregated.deals_count, 0) AS deals_count
FROM
    backbone AS backbone
LEFT JOIN
    aggregated AS aggregated
    ON backbone.month = aggregated.month
    AND backbone.funnel_step = aggregated.funnel_step
ORDER BY
    1,
    2