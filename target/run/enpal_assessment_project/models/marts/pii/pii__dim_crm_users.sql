
  
    

  create  table "postgres"."pii"."pii__dim_crm_users__dbt_tmp"
  
  
    as
  
  (
    
SELECT
    user_id,
    user_name,
    email
FROM
    "postgres"."staging"."stg_pipedrive_users"
  );
  