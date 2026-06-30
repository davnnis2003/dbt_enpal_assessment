
  create view "postgres"."staging"."stg_pipedrive_activity_types__dbt_tmp"
    
    
  as (
    
WITH
    source AS (
        SELECT
            *
        FROM
            "postgres"."s_pipedrive"."activity_types"
    ),
    renamed AS (
        SELECT
            cast(id AS integer) AS activity_type_id,
            cast(name AS varchar) AS activity_type_name,
            CASE
                WHEN active = 'Yes' THEN TRUE
                WHEN active = 'No' THEN FALSE
                ELSE NULL
            END AS is_active,
            cast(type AS varchar) AS activity_type_category
        FROM
            source
    )
SELECT
    *
FROM
    renamed
  );