
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select activity_type_id
from "postgres"."pipedrive_analytics"."mart__dim_crm_activity_types"
where activity_type_id is null



  
  
      
    ) dbt_internal_test