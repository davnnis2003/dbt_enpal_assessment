
      
        
        
        delete from "postgres"."marts"."fct_crm_deal_changes" as DBT_INTERNAL_DEST
        where (deal_change_id) in (
            select distinct deal_change_id
            from "fct_crm_deal_changes__dbt_tmp124323008664" as DBT_INTERNAL_SOURCE
        );

    

    insert into "postgres"."marts"."fct_crm_deal_changes" ("deal_change_id", "deal_id", "deal_created_at_utc", "deal_created_at_berlin", "changed_at_utc", "changed_at_berlin", "changed_field_key", "field_name", "old_value", "new_value", "old_value_resolved", "new_value_resolved", "old_stage_id", "old_stage_name", "old_user_id", "old_lost_reason_id", "old_lost_reason_label", "new_stage_id", "new_stage_name", "new_user_id", "new_lost_reason_id", "new_lost_reason_label")
    (
        select "deal_change_id", "deal_id", "deal_created_at_utc", "deal_created_at_berlin", "changed_at_utc", "changed_at_berlin", "changed_field_key", "field_name", "old_value", "new_value", "old_value_resolved", "new_value_resolved", "old_stage_id", "old_stage_name", "old_user_id", "old_lost_reason_id", "old_lost_reason_label", "new_stage_id", "new_stage_name", "new_user_id", "new_lost_reason_id", "new_lost_reason_label"
        from "fct_crm_deal_changes__dbt_tmp124323008664"
    )
  