
WITH
    activities AS (
        SELECT
            *
        FROM
            "postgres"."staging"."stg_pipedrive_activities" AS stg_pipedrive_activities
        
    ),
    activity_types AS (
        SELECT
            *
        FROM
            "postgres"."marts"."dim_crm_activity_types"
    )
SELECT
    activities.activity_id AS activity_id,
    activities.activity_type_category AS activity_type_category,
    activity_types.activity_type_id AS activity_type_id,
    activity_types.activity_type_name AS activity_type_name,
    activities.assigned_user_id AS assigned_user_id,
    activities.deal_id AS deal_id,
    activities.is_done AS is_done,
    activities.due_at_utc AS due_at_utc,
    activities.due_at_berlin AS due_at_berlin
FROM
    activities AS activities
LEFT JOIN
    activity_types AS activity_types
    ON activities.activity_type_category = activity_types.activity_type_category

-- TODO: Explore JOIN with Deals Changes fact table later