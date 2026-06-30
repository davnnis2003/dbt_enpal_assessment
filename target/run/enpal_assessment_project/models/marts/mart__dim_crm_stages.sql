
  
    

  create  table "postgres"."marts"."dim_crm_stages__dbt_tmp"
  
  
    as
  
  (
    
SELECT
    stage_id,
    stage_name
FROM
    "postgres"."staging"."stg_pipedrive_stages"
  );
  