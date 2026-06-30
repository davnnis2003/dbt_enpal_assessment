
  
    

  create  table "postgres"."marts"."dim_crm_fields__dbt_tmp"
  
  
    as
  
  (
    
SELECT
    field_id,
    field_key,
    field_name
FROM
    "postgres"."staging"."stg_pipedrive_fields"
  );
  