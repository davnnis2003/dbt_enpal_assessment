{{ config(
    materialized='table',
    schema='pii',
    alias='dim_crm_users'
) }}
SELECT
    user_id,
    user_name,
    email
FROM
    {{ ref('stg_pipedrive_users') }}
