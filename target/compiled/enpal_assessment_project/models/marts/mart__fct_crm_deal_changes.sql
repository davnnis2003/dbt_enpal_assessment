

-- TODO: Make this model incremental later to optimize run time.


WITH
    deal_changes AS (
        SELECT
            *
        FROM
            "postgres"."staging"."stg_pipedrive_deal_changes"
    ),
    deal_changes_with_lag AS (
        SELECT
            deal_change_id AS deal_change_id,
            deal_id AS deal_id,
            changed_at_utc AS changed_at_utc,
            changed_at_berlin AS changed_at_berlin,
            changed_field_key AS changed_field_key,
            new_value AS new_value,
            LAG(new_value) OVER (
                PARTITION BY deal_id, changed_field_key 
                ORDER BY changed_at_utc
            ) AS old_value
        FROM
            deal_changes
    ),
    deal_created_times AS (
        SELECT
            deal_id AS deal_id,
            MIN(changed_at_utc) AS deal_created_at_utc,
            MIN(changed_at_berlin) AS deal_created_at_berlin
        FROM
            deal_changes
        WHERE
            changed_field_key = 'add_time'
        GROUP BY
            deal_id
    ),
    fields AS (
        SELECT
            *
        FROM
            "postgres"."marts"."dim_crm_fields"
    ),
    stages AS (
        SELECT
            *
        FROM
            "postgres"."marts"."dim_crm_stages"
    ),
    field_options AS (
        SELECT
            *
        FROM
            "postgres"."marts"."dim_crm_field_options"
        WHERE
            field_key = 'lost_reason'
    )
SELECT
    deal_changes_with_lag.deal_change_id AS deal_change_id,
    deal_changes_with_lag.deal_id AS deal_id,
    deal_created_times.deal_created_at_utc AS deal_created_at_utc,
    deal_created_times.deal_created_at_berlin AS deal_created_at_berlin,
    deal_changes_with_lag.changed_at_utc AS changed_at_utc,
    deal_changes_with_lag.changed_at_berlin AS changed_at_berlin,
    deal_changes_with_lag.changed_field_key AS changed_field_key,
    fields.field_name AS field_name,
    deal_changes_with_lag.old_value AS old_value,
    deal_changes_with_lag.new_value AS new_value,
    
    -- Resolved values for key fields (Old)
    CASE
        WHEN deal_changes_with_lag.changed_field_key = 'stage_id' THEN stages_old.stage_name
        WHEN deal_changes_with_lag.changed_field_key = 'lost_reason' THEN field_options_old.option_label
        ELSE deal_changes_with_lag.old_value
    END AS old_value_resolved,
    
    -- Resolved values for key fields (New)
    CASE
        WHEN deal_changes_with_lag.changed_field_key = 'stage_id' THEN stages_new.stage_name
        WHEN deal_changes_with_lag.changed_field_key = 'lost_reason' THEN field_options_new.option_label
        ELSE deal_changes_with_lag.new_value
    END AS new_value_resolved,
    
    -- Structured typed columns (Old)
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'stage_id' AND deal_changes_with_lag.old_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.old_value AS integer)
    END AS old_stage_id,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'stage_id' THEN stages_old.stage_name
    END AS old_stage_name,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'user_id' AND deal_changes_with_lag.old_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.old_value AS integer)
    END AS old_user_id,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'lost_reason' AND deal_changes_with_lag.old_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.old_value AS integer)
    END AS old_lost_reason_id,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'lost_reason' THEN field_options_old.option_label
    END AS old_lost_reason_label,
    
    -- Structured typed columns (New)
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'stage_id' AND deal_changes_with_lag.new_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.new_value AS integer)
    END AS new_stage_id,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'stage_id' THEN stages_new.stage_name
    END AS new_stage_name,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'user_id' AND deal_changes_with_lag.new_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.new_value AS integer)
    END AS new_user_id,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'lost_reason' AND deal_changes_with_lag.new_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.new_value AS integer)
    END AS new_lost_reason_id,
    CASE 
        WHEN deal_changes_with_lag.changed_field_key = 'lost_reason' THEN field_options_new.option_label
    END AS new_lost_reason_label

FROM
    deal_changes_with_lag AS deal_changes_with_lag
LEFT JOIN
    deal_created_times AS deal_created_times
    ON deal_changes_with_lag.deal_id = deal_created_times.deal_id
LEFT JOIN
    fields AS fields
    ON deal_changes_with_lag.changed_field_key = fields.field_key
    
-- Joins for Old Values
LEFT JOIN
    stages AS stages_old
    ON deal_changes_with_lag.changed_field_key = 'stage_id' 
    AND CASE WHEN deal_changes_with_lag.old_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.old_value AS integer) END = stages_old.stage_id
LEFT JOIN
    field_options AS field_options_old
    ON deal_changes_with_lag.changed_field_key = 'lost_reason' 
    AND CASE WHEN deal_changes_with_lag.old_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.old_value AS integer) END = field_options_old.option_id
    
-- Joins for New Values
LEFT JOIN
    stages AS stages_new
    ON deal_changes_with_lag.changed_field_key = 'stage_id' 
    AND CASE WHEN deal_changes_with_lag.new_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.new_value AS integer) END = stages_new.stage_id
LEFT JOIN
    field_options AS field_options_new
    ON deal_changes_with_lag.changed_field_key = 'lost_reason' 
    AND CASE WHEN deal_changes_with_lag.new_value ~ '^[0-9]+$' THEN CAST(deal_changes_with_lag.new_value AS integer) END = field_options_new.option_id

WHERE
    deal_changes_with_lag.changed_at_utc >= (SELECT MAX(changed_at_utc) FROM "postgres"."marts"."fct_crm_deal_changes")
