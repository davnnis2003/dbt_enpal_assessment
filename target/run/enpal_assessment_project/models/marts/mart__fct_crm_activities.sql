
      
        
        
        delete from "postgres"."marts"."fct_crm_activities" as DBT_INTERNAL_DEST
        where (activity_id) in (
            select distinct activity_id
            from "fct_crm_activities__dbt_tmp144805286762" as DBT_INTERNAL_SOURCE
        );

    

    insert into "postgres"."marts"."fct_crm_activities" ("activity_id", "activity_type_category", "activity_type_id", "activity_type_name", "assigned_user_id", "deal_id", "is_done", "due_at_utc", "due_at_berlin")
    (
        select "activity_id", "activity_type_category", "activity_type_id", "activity_type_name", "assigned_user_id", "deal_id", "is_done", "due_at_utc", "due_at_berlin"
        from "fct_crm_activities__dbt_tmp144805286762"
    )
  