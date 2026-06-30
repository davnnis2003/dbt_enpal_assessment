{{ config(
    materialized='table',
    schema='marts',
    alias='fct_crm_activities'
) }}
WITH
    activities AS (
        SELECT
            *
        FROM
            {{ ref('stg_pipedrive_activities') }}
    ),
    activity_types AS (
        SELECT
            *
        FROM
            {{ ref('mart__dim_crm_activity_types') }}
    )
SELECT
    activities.activity_id,
    activities.activity_type_category,
    activity_types.activity_type_id,
    activity_types.activity_type_name,
    activities.assigned_user_id,
    activities.deal_id,
    activities.is_done,
    activities.due_at_utc,
    activities.due_at_berlin
FROM
    activities
LEFT JOIN
    activity_types
    ON activities.activity_type_category = activity_types.activity_type_category

-- TODO: Explore JOIN with Deals Changes fact table later

