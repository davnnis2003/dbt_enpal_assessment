
  create view "postgres"."staging"."stg_pipedrive_activities__dbt_tmp"
    
    
  as (
    
WITH
    source AS (
        SELECT
            *
        FROM
            -- raw data ingested via dbt seed, not an external source
            "postgres"."s_pipedrive"."activity"
    ),
    renamed AS (
        SELECT
            cast(activity_id AS integer) AS activity_id,
            cast(type AS varchar) AS activity_type_category,
            cast(assigned_to_user AS integer) AS assigned_user_id,
            cast(deal_id AS integer) AS deal_id,
            cast(done AS boolean) AS is_done,
            cast(due_to AS timestamp) AS due_at_utc,
            cast(due_to AS timestamp) AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Berlin' AS due_at_berlin
        FROM
            source
    ),
    -- NOTE: Exploratory analysis revealed that records with duplicate activity_id exist in raw data,
    -- but they carry different type, assigned_to_user, and deal_id values. The root cause is unclear
    -- (likely a sync/state bug in Pipedrive). 
    -- 
    -- Alternatively, if these rows represent unique business interactions, they could be preserved 
    -- by constructing a compound surrogate key (e.g. hash of activity_id + deal_id). However, this 
    -- would introduce extra complexity downstream (additional join conditions, downstream duplication risk).
    -- 
    -- Given the very low magnitude of the issue (only ~10 duplicate records out of ~4,500 total rows),
    -- we enforce grain deduplication here to ensure unique activity_id by selecting the latest record
    -- based on due date.
    deduplicated AS (
        SELECT
            *,
            row_number() OVER (PARTITION BY activity_id ORDER BY due_at_utc DESC) AS row_num
        FROM
            renamed
    )
SELECT
    activity_id,
    activity_type_category,
    assigned_user_id,
    deal_id,
    is_done,
    due_at_utc,
    due_at_berlin
FROM
    deduplicated
WHERE
    row_num = 1
  );