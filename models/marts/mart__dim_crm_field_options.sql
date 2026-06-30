{{ config(
    materialized='table',
    schema='marts',
    alias='dim_crm_field_options'
) }}
SELECT
    field_id,
    field_key,
    field_name,
    cast(opt->>'id' AS integer) AS option_id,
    cast(opt->>'label' AS varchar) AS option_label
FROM
    {{ ref('stg_pipedrive_fields') }},
    jsonb_array_elements(field_value_options) AS opt
