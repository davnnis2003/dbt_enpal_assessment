
    
    

select
    deal_change_id as unique_field,
    count(*) as n_records

from "postgres"."staging"."stg_pipedrive_deal_changes"
where deal_change_id is not null
group by deal_change_id
having count(*) > 1


