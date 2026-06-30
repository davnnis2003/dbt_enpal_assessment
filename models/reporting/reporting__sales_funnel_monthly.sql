{{ config(
    materialized='table',
    schema='reporting',
    alias='sales_funnel_monthly'
) }}

WITH
    daily_entries AS (
        SELECT
            *
        FROM
            {{ ref('mart__sum_crm_daily_summary') }}
    )
SELECT
    CAST(DATE_TRUNC('month', daily_entries.summary_date) AS DATE) AS month,
    daily_entries.funnel_step AS funnel_step,
    daily_entries.kpi_name AS kpi_name,
    COUNT(DISTINCT daily_entries.deal_id) AS deals_count
FROM
    daily_entries AS daily_entries
GROUP BY
    CAST(DATE_TRUNC('month', daily_entries.summary_date) AS DATE),
    daily_entries.funnel_step,
    daily_entries.kpi_name
ORDER BY
    month ASC,
    CASE
        WHEN daily_entries.funnel_step = '1' THEN 1
        WHEN daily_entries.funnel_step = '2' THEN 2
        WHEN daily_entries.funnel_step = '2.1' THEN 3
        WHEN daily_entries.funnel_step = '3' THEN 4
        WHEN daily_entries.funnel_step = '3.1' THEN 5
        WHEN daily_entries.funnel_step = '4' THEN 6
        WHEN daily_entries.funnel_step = '5' THEN 7
        WHEN daily_entries.funnel_step = '6' THEN 8
        WHEN daily_entries.funnel_step = '7' THEN 9
        WHEN daily_entries.funnel_step = '8' THEN 10
        WHEN daily_entries.funnel_step = '9' THEN 11
        ELSE 12
    END ASC
