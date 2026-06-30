{{ config(
    materialized='view',
    schema='staging'
) }}

with source as (
    select * from {{ source('postgres_public', 'fields') }}
),

renamed as (
    select
        cast(id as integer) as field_id,
        cast(field_key as varchar) as field_key,
        cast(name as varchar) as field_name,
        field_value_options

    from source
)

select * from renamed
