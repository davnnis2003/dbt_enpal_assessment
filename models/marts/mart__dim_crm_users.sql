{{ config(
    materialized='table',
    schema='marts',
    alias='dim_crm_users'
) }}
SELECT
    user_id,
    modified_at_utc,
    modified_at_berlin
FROM
    {{ ref('stg_pipedrive_users') }}
