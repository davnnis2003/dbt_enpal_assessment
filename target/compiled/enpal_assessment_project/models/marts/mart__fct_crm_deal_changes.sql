

WITH
    deal_changes AS (
        SELECT
            *
        FROM
            "postgres"."staging"."stg_pipedrive_deal_changes"
    ),
    deal_changes_with_lag AS (
        SELECT
            deal_change_id,
            deal_id,
            changed_at_utc,
            changed_at_berlin,
            changed_field_key,
            new_value,
            LAG(new_value) OVER (
                PARTITION BY deal_id, changed_field_key 
                ORDER BY changed_at_utc
            ) AS old_value
        FROM
            deal_changes
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
    dc.deal_change_id,
    dc.deal_id,
    dc.changed_at_utc,
    dc.changed_at_berlin,
    dc.changed_field_key,
    f.field_name,
    dc.old_value,
    dc.new_value,
    
    -- Resolved values for key fields (Old)
    CASE
        WHEN dc.changed_field_key = 'stage_id' THEN s_old.stage_name
        WHEN dc.changed_field_key = 'lost_reason' THEN fo_old.option_label
        ELSE dc.old_value
    END AS old_value_resolved,
    
    -- Resolved values for key fields (New)
    CASE
        WHEN dc.changed_field_key = 'stage_id' THEN s_new.stage_name
        WHEN dc.changed_field_key = 'lost_reason' THEN fo_new.option_label
        ELSE dc.new_value
    END AS new_value_resolved,
    
    -- Structured typed columns (Old)
    CASE 
        WHEN dc.changed_field_key = 'stage_id' AND dc.old_value ~ '^[0-9]+$' THEN cast(dc.old_value AS integer)
    END AS old_stage_id,
    CASE 
        WHEN dc.changed_field_key = 'stage_id' THEN s_old.stage_name
    END AS old_stage_name,
    CASE 
        WHEN dc.changed_field_key = 'user_id' AND dc.old_value ~ '^[0-9]+$' THEN cast(dc.old_value AS integer)
    END AS old_user_id,
    CASE 
        WHEN dc.changed_field_key = 'lost_reason' AND dc.old_value ~ '^[0-9]+$' THEN cast(dc.old_value AS integer)
    END AS old_lost_reason_id,
    CASE 
        WHEN dc.changed_field_key = 'lost_reason' THEN fo_old.option_label
    END AS old_lost_reason_label,
    
    -- Structured typed columns (New)
    CASE 
        WHEN dc.changed_field_key = 'stage_id' AND dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer)
    END AS new_stage_id,
    CASE 
        WHEN dc.changed_field_key = 'stage_id' THEN s_new.stage_name
    END AS new_stage_name,
    CASE 
        WHEN dc.changed_field_key = 'user_id' AND dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer)
    END AS new_user_id,
    CASE 
        WHEN dc.changed_field_key = 'lost_reason' AND dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer)
    END AS new_lost_reason_id,
    CASE 
        WHEN dc.changed_field_key = 'lost_reason' THEN fo_new.option_label
    END AS new_lost_reason_label

FROM
    deal_changes_with_lag AS dc
LEFT JOIN
    fields AS f
    ON dc.changed_field_key = f.field_key
    
-- Joins for Old Values
LEFT JOIN
    stages AS s_old
    ON dc.changed_field_key = 'stage_id' 
    AND CASE WHEN dc.old_value ~ '^[0-9]+$' THEN cast(dc.old_value AS integer) END = s_old.stage_id
LEFT JOIN
    field_options AS fo_old
    ON dc.changed_field_key = 'lost_reason' 
    AND CASE WHEN dc.old_value ~ '^[0-9]+$' THEN cast(dc.old_value AS integer) END = fo_old.option_id
    
-- Joins for New Values
LEFT JOIN
    stages AS s_new
    ON dc.changed_field_key = 'stage_id' 
    AND CASE WHEN dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer) END = s_new.stage_id
LEFT JOIN
    field_options AS fo_new
    ON dc.changed_field_key = 'lost_reason' 
    AND CASE WHEN dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer) END = fo_new.option_id