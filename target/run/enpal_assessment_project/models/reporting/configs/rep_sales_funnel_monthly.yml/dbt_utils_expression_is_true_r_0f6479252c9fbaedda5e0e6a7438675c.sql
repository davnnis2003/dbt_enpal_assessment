
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "postgres"."reporting"."rep_sales_funnel_monthly"

where not(deals_count >= 0)


  
  
      
    ) dbt_internal_test