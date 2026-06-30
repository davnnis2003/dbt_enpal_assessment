{{ config(
    materialized='table',
    alias='dim_crm_fields'
) }}
SELECT
    field_id,
    field_key,
    field_name,
    field_value_options
FROM
    {{ ref('stg_pipedrive_fields') }}
