
WITH
    source AS (
        SELECT
            *
        FROM
            "postgres"."s_pipedrive"."stages"
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