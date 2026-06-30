
SELECT
    activity_type_id,
    activity_type_name,
    is_active,
    activity_type_category
FROM
    "postgres"."staging"."stg_pipedrive_activity_types"