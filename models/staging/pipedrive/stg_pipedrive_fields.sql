{{ config(
    materialized='view',
    schema='staging',
    alias='stg_pipedrive_fields'
) }}
WITH
    source AS (
        SELECT
            *
        FROM
            -- raw data ingested via dbt seed, not an external source
            {{ ref('fields') }}
    ),
    renamed AS (
        SELECT
            cast(id AS integer) AS field_id,
            cast(field_key AS varchar) AS field_key,
            cast(name AS varchar) AS field_name,
            field_value_options
        FROM
            source
    )
SELECT
    *
FROM
    renamed