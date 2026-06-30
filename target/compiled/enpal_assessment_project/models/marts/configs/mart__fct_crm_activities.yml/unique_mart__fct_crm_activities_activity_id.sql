
    
    

select
    activity_id as unique_field,
    count(*) as n_records

from "postgres"."marts"."fct_crm_activities"
where activity_id is not null
group by activity_id
having count(*) > 1


