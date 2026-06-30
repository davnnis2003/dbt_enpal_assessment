{{ config(
    materialized='table',
    schema='pii'
) }}
SELECT
    user_id,
    user_name,
    email
FROM
    {{ ref('stg_pipedrive_users') }}
