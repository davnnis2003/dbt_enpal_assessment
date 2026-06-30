{{ config(
    materialized='table'
) }}
SELECT
    stage_id,
    stage_name
FROM
    {{ ref('stg_pipedrive_stages') }}
