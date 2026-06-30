
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select option_id
from "postgres"."marts"."dim_crm_field_options"
where option_id is null



  
  
      
    ) dbt_internal_test