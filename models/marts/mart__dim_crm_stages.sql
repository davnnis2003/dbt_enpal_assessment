{{ config(
    materialized='table',
    schema='marts',
    alias='dim_crm_stages'
) }}
SELECT
    stage_id,
    stage_name
FROM
    {{ ref('stg_pipedrive_stages') }}
