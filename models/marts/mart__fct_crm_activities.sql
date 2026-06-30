{{ config(
    materialized='incremental',
    schema='marts',
    alias='fct_crm_activities',
    unique_key='activity_id',
    on_schema_change='sync_all_columns'
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
    activities.activity_id AS activity_id,
    activities.activity_type_category AS activity_type_category,
    activity_types.activity_type_id AS activity_type_id,
    activity_types.activity_type_name AS activity_type_name,
    activities.assigned_user_id AS assigned_user_id,
    activities.deal_id AS deal_id,
    activities.is_done AS is_done,
    activities.due_at_utc AS due_at_utc,
    activities.due_at_berlin AS due_at_berlin
FROM
    activities AS activities
LEFT JOIN
    activity_types AS activity_types
    ON activities.activity_type_category = activity_types.activity_type_category
{% if is_incremental() %}
WHERE
    {{ get_incremental_date_filter('activities.due_at_utc', 'due_at_utc') }}
{% endif %}

-- TODO: Explore JOIN with Deals Changes fact table later

