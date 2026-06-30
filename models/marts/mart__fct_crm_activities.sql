{{ config(
    materialized='table',
    schema='marts',
    alias='fct_crm_activities'
) }}
SELECT
    activity_id,
    activity_type_category,
    assigned_user_id,
    deal_id,
    is_done,
    due_at_utc,
    due_at_berlin
FROM
    {{ ref('stg_pipedrive_activities') }}
