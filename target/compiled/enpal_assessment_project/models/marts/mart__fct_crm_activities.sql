
WITH
    activities AS (
        SELECT
            *
        FROM
            "postgres"."staging"."stg_pipedrive_activities"
    ),
    activity_types AS (
        SELECT
            *
        FROM
            "postgres"."marts"."dim_crm_activity_types"
    )
SELECT
    activities.activity_id,
    activities.activity_type_category,
    activity_types.activity_type_id,
    activity_types.activity_type_name,
    activities.assigned_user_id,
    activities.deal_id,
    activities.is_done,
    activities.due_at_utc,
    activities.due_at_berlin
FROM
    activities
LEFT JOIN
    activity_types
    ON activities.activity_type_category = activity_types.activity_type_category