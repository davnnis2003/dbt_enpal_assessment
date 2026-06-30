
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select field_id
from "postgres"."marts"."dim_crm_field_options"
where field_id is null



  
  
      
    ) dbt_internal_test