with source as (
    select * from "postgres"."public"."activity_types"
),

renamed as (
    select
        cast(id as integer) as activity_type_id,
        cast(name as varchar) as activity_type_name,
        case
            when active = 'Yes' then true
            when active = 'No' then false
            else null
        end as is_active,
        cast(type as varchar) as activity_type_category

    from source
)

select * from renamed