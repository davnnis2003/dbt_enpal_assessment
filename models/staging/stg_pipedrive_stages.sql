{{ config(
    materialized='view',
    schema='staging',
    alias='stg_pipedrive_stages'
) }}
WITH
    source AS (
        SELECT
            *
        FROM
            {{ source('postgres_public', 'stages') }}
    ),
    renamed AS (
        SELECT
            cast(stage_id AS integer) AS stage_id,
            cast(stage_name AS varchar) AS stage_name
        FROM
            source
    )
SELECT
    *
FROM
    renamed
