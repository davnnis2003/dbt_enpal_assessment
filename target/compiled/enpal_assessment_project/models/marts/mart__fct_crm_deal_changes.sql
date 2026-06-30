

-- TODO: Make this model incremental later to optimize run time.


WITH
    deal_changes_raw AS (
        SELECT
            stg_pipedrive_deal_changes.deal_change_id AS deal_change_id,
            stg_pipedrive_deal_changes.deal_id AS deal_id,
            stg_pipedrive_deal_changes.changed_at_utc AS changed_at_utc,
            stg_pipedrive_deal_changes.changed_at_berlin AS changed_at_berlin,
            stg_pipedrive_deal_changes.changed_field_key AS changed_field_key,
            stg_pipedrive_deal_changes.new_value AS new_value,
            LAG(stg_pipedrive_deal_changes.new_value) OVER (
                PARTITION BY stg_pipedrive_deal_changes.deal_id, stg_pipedrive_deal_changes.changed_field_key 
                ORDER BY stg_pipedrive_deal_changes.changed_at_utc
            ) AS old_value
        FROM
            "postgres"."staging"."stg_pipedrive_deal_changes" AS stg_pipedrive_deal_changes
    ),
    deal_created_times AS (
        SELECT
            deal_changes_raw.deal_id AS deal_id,
            MIN(deal_changes_raw.changed_at_utc) AS deal_created_at_utc,
            MIN(deal_changes_raw.changed_at_berlin) AS deal_created_at_berlin
        FROM
            deal_changes_raw AS deal_changes_raw
        WHERE
            deal_changes_raw.changed_field_key = 'add_time'
        GROUP BY
            deal_changes_raw.deal_id
    ),
    deal_changes AS (
        SELECT
            deal_changes_raw.deal_change_id AS deal_change_id,
            deal_changes_raw.deal_id AS deal_id,
            deal_changes_raw.changed_at_utc AS changed_at_utc,
            deal_changes_raw.changed_at_berlin AS changed_at_berlin,
            deal_changes_raw.changed_field_key AS changed_field_key,
            deal_changes_raw.old_value AS old_value,
            deal_changes_raw.new_value AS new_value,
            CASE 
                WHEN deal_changes_raw.old_value ~ '^[0-9]+$' THEN CAST(deal_changes_raw.old_value AS integer) 
            END AS _old_value_as_int,
            CASE 
                WHEN deal_changes_raw.new_value ~ '^[0-9]+$' THEN CAST(deal_changes_raw.new_value AS integer) 
            END AS _new_value_as_int
        FROM
            deal_changes_raw AS deal_changes_raw
        
        WHERE
            
    deal_changes_raw.changed_at_utc >= (SELECT MAX(changed_at_utc) FROM "postgres"."marts"."fct_crm_deal_changes")

        
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
    lost_reasons AS (
        SELECT
            *
        FROM
            "postgres"."marts"."dim_crm_field_options"
        WHERE
            field_key = 'lost_reason'
    )
SELECT
    deal_changes.deal_change_id AS deal_change_id,
    deal_changes.deal_id AS deal_id,
    deal_created_times.deal_created_at_utc AS deal_created_at_utc,
    deal_created_times.deal_created_at_berlin AS deal_created_at_berlin,
    deal_changes.changed_at_utc AS changed_at_utc,
    deal_changes.changed_at_berlin AS changed_at_berlin,
    deal_changes.changed_field_key AS changed_field_key,
    fields.field_name AS field_name,
    deal_changes.old_value AS old_value,
    deal_changes.new_value AS new_value,
    
    -- Resolved values for key fields (Old)
    CASE
        WHEN deal_changes.changed_field_key = 'stage_id' THEN stages_old.stage_name
        WHEN deal_changes.changed_field_key = 'lost_reason' THEN lost_reasons_old.option_label
        ELSE deal_changes.old_value
    END AS old_value_resolved,
    
    -- Resolved values for key fields (New)
    CASE
        WHEN deal_changes.changed_field_key = 'stage_id' THEN stages_new.stage_name
        WHEN deal_changes.changed_field_key = 'lost_reason' THEN lost_reasons_new.option_label
        ELSE deal_changes.new_value
    END AS new_value_resolved,
    
    -- Structured typed columns (Old)
    CASE 
        WHEN deal_changes.changed_field_key = 'stage_id' THEN deal_changes._old_value_as_int
    END AS old_stage_id,
    CASE 
        WHEN deal_changes.changed_field_key = 'stage_id' THEN stages_old.stage_name
    END AS old_stage_name,
    CASE 
        WHEN deal_changes.changed_field_key = 'user_id' THEN deal_changes._old_value_as_int
    END AS old_user_id,
    CASE 
        WHEN deal_changes.changed_field_key = 'lost_reason' THEN deal_changes._old_value_as_int
    END AS old_lost_reason_id,
    CASE 
        WHEN deal_changes.changed_field_key = 'lost_reason' THEN lost_reasons_old.option_label
    END AS old_lost_reason_label,
    
    -- Structured typed columns (New)
    CASE 
        WHEN deal_changes.changed_field_key = 'stage_id' THEN deal_changes._new_value_as_int
    END AS new_stage_id,
    CASE 
        WHEN deal_changes.changed_field_key = 'stage_id' THEN stages_new.stage_name
    END AS new_stage_name,
    CASE 
        WHEN deal_changes.changed_field_key = 'user_id' THEN deal_changes._new_value_as_int
    END AS new_user_id,
    CASE 
        WHEN deal_changes.changed_field_key = 'lost_reason' THEN deal_changes._new_value_as_int
    END AS new_lost_reason_id,
    CASE 
        WHEN deal_changes.changed_field_key = 'lost_reason' THEN lost_reasons_new.option_label
    END AS new_lost_reason_label

FROM
    deal_changes AS deal_changes
LEFT JOIN
    deal_created_times AS deal_created_times
    ON deal_changes.deal_id = deal_created_times.deal_id
LEFT JOIN
    fields AS fields
    ON deal_changes.changed_field_key = fields.field_key
    
-- Joins for Old Values
LEFT JOIN
    stages AS stages_old
    ON deal_changes.changed_field_key = 'stage_id' 
    AND deal_changes._old_value_as_int = stages_old.stage_id
LEFT JOIN
    lost_reasons AS lost_reasons_old
    ON deal_changes.changed_field_key = 'lost_reason' 
    AND deal_changes._old_value_as_int = lost_reasons_old.option_id
    
-- Joins for New Values
LEFT JOIN
    stages AS stages_new
    ON deal_changes.changed_field_key = 'stage_id' 
    AND deal_changes._new_value_as_int = stages_new.stage_id
LEFT JOIN
    lost_reasons AS lost_reasons_new
    ON deal_changes.changed_field_key = 'lost_reason' 
    AND deal_changes._new_value_as_int = lost_reasons_new.option_id