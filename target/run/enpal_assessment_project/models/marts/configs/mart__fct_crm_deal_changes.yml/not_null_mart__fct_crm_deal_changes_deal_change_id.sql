
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select deal_change_id
from "postgres"."marts"."fct_crm_deal_changes"
where deal_change_id is null



  
  
      
    ) dbt_internal_test