
  
    

  create  table "postgres"."marts"."dim_crm_users__dbt_tmp"
  
  
    as
  
  (
    
SELECT
    stg_pipedrive_users.user_id AS user_id,
    stg_pipedrive_users.user_name AS user_name,
    stg_pipedrive_users.email AS email,
    stg_pipedrive_users.modified_at_utc AS modified_at_utc,
    stg_pipedrive_users.modified_at_berlin AS modified_at_berlin
FROM
    "postgres"."staging"."stg_pipedrive_users" AS stg_pipedrive_users
-- Note: Due to GDPR data retention policy, internal employee PII data should be auto-deleted after 6 months.
-- For production, this can be filtered or cleaned up dynamically:
-- WHERE stg_pipedrive_users.modified_at_utc >= CURRENT_TIMESTAMP - INTERVAL '6 MONTH'
  );
  