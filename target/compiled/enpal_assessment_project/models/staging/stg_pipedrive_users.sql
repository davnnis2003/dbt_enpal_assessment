
WITH
    source AS (
        SELECT
            *
        FROM
            "postgres"."public"."users"
    ),
    renamed AS (
        SELECT
            cast(id AS integer) AS user_id,
            cast(name AS varchar) AS user_name,
            cast(email AS varchar) AS email,
            cast(modified AS timestamp) AS modified_at_utc,
            cast(modified AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Berlin' AS modified_at_berlin
        FROM
            source
    )
SELECT
    *
FROM
    renamed