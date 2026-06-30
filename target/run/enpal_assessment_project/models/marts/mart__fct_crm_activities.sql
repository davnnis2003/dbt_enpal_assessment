
  
    

  create  table "postgres"."marts"."fct_crm_activities__dbt_tmp"
  
  
    as
  
  (
    
SELECT
    activity_id,
    activity_type_category,
    assigned_user_id,
    deal_id,
    is_done,
    due_at_utc,
    due_at_berlin
FROM
    "postgres"."staging"."stg_pipedrive_activities"
  );
  