{{ config(
    materialized='table',
    schema='marts',
    alias='dim_crm_fields'
) }}
SELECT
    field_id,
    field_key,
    field_name
FROM
    {{ ref('stg_pipedrive_fields') }}
