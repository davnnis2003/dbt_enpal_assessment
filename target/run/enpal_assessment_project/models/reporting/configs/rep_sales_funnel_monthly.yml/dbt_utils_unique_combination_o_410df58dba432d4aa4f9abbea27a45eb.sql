
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        month, funnel_step
    from "postgres"."reporting"."rep_sales_funnel_monthly"
    group by month, funnel_step
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test