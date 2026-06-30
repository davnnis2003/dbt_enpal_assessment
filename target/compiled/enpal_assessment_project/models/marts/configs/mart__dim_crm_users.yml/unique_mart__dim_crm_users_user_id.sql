
    
    

select
    user_id as unique_field,
    count(*) as n_records

from "postgres"."marts"."dim_crm_users"
where user_id is not null
group by user_id
having count(*) > 1


