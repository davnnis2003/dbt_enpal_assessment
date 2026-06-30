
  
    

  create  table "postgres"."marts"."dim_crm_users__dbt_tmp"
  
  
    as
  
  (
    
SELECT
    user_id,
    modified_at_utc,
    modified_at_berlin
FROM
    "postgres"."staging"."stg_pipedrive_users"
  );
  