{{ config(
    materialized='table'
) }}
SELECT
    activity_type_id,
    activity_type_name,
    is_active,
    activity_type_category
FROM
    {{ ref('stg_pipedrive_activity_types') }}
