
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select deal_id
from "postgres"."marts"."sum_crm_daily_summary"
where deal_id is null



  
  
      
    ) dbt_internal_test