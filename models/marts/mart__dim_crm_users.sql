{{ config(
    materialized='table',
    schema='marts',
    alias='dim_crm_users'
) }}
SELECT
    stg_pipedrive_users.user_id AS user_id,
    stg_pipedrive_users.user_name AS user_name,
    stg_pipedrive_users.email AS email,
    stg_pipedrive_users.modified_at_utc AS modified_at_utc,
    stg_pipedrive_users.modified_at_berlin AS modified_at_berlin
FROM
    {{ ref('stg_pipedrive_users') }} AS stg_pipedrive_users
-- Note: Due to GDPR data retention policy, internal employee PII data should be auto-deleted after 6 months.
-- For production, this can be filtered or cleaned up dynamically:
-- WHERE stg_pipedrive_users.modified_at_utc >= CURRENT_TIMESTAMP - INTERVAL '6 MONTH'
