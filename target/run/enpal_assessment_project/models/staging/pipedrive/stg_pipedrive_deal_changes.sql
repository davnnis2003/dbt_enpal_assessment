
  create view "postgres"."staging"."stg_pipedrive_deal_changes__dbt_tmp"
    
    
  as (
    
WITH
    source AS (
        SELECT
            *
        FROM
            "postgres"."public"."deal_changes"
    ),
    renamed AS (
        SELECT
            md5(concat(
                coalesce(cast(deal_id AS varchar), ''), '-',
                coalesce(cast(change_time AS varchar), ''), '-',
                coalesce(cast(changed_field_key AS varchar), '')
            )) AS deal_change_id,
            cast(deal_id AS integer) AS deal_id,
            cast(change_time AS timestamp) AS changed_at_utc,
            cast(change_time AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Berlin' AS changed_at_berlin,
            cast(changed_field_key AS varchar) AS changed_field_key,
            cast(new_value AS varchar) AS new_value
        FROM
            source
    )
SELECT
    *
FROM
    renamed
  );