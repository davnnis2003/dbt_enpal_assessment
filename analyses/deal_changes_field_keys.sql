SELECT
    stg_pipedrive_deal_changes.changed_field_key AS changed_field_key,
    COUNT(*) AS change_count
FROM {{ ref('stg_pipedrive_deal_changes') }} AS stg_pipedrive_deal_changes
GROUP BY
    stg_pipedrive_deal_changes.changed_field_key
ORDER BY
    change_count DESC
