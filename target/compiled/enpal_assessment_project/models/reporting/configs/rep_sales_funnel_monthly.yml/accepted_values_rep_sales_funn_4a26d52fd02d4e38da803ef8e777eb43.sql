
    
    

with all_values as (

    select
        funnel_step as value_field,
        count(*) as n_records

    from "postgres"."reporting"."rep_sales_funnel_monthly"
    group by funnel_step

)

select *
from all_values
where value_field not in (
    '1','2','2.1','3','3.1','4','5','6','7','8','9'
)


