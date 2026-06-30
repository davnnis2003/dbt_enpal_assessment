
  
    

  create  table "postgres"."marts"."fct_crm_deal_changes__dbt_tmp"
  
  
    as
  
  (
    

WITH
    deal_changes AS (
        SELECT
            *
        FROM
            "postgres"."staging"."stg_pipedrive_deal_changes"
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
    dc.new_value,
    -- Resolved values for key fields
    CASE
        WHEN dc.changed_field_key = 'stage_id' THEN s.stage_name
        WHEN dc.changed_field_key = 'lost_reason' THEN fo.option_label
        ELSE dc.new_value
    END AS new_value_resolved,
    -- Structured typed columns
    CASE 
        WHEN dc.changed_field_key = 'stage_id' AND dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer)
    END AS new_stage_id,
    CASE 
        WHEN dc.changed_field_key = 'stage_id' THEN s.stage_name
    END AS new_stage_name,
    CASE 
        WHEN dc.changed_field_key = 'user_id' AND dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer)
    END AS new_user_id,
    CASE 
        WHEN dc.changed_field_key = 'lost_reason' AND dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer)
    END AS new_lost_reason_id,
    CASE 
        WHEN dc.changed_field_key = 'lost_reason' THEN fo.option_label
    END AS new_lost_reason_label
FROM
    deal_changes AS dc
LEFT JOIN
    fields AS f
    ON dc.changed_field_key = f.field_key
LEFT JOIN
    stages AS s
    ON dc.changed_field_key = 'stage_id' 
    AND CASE WHEN dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer) END = s.stage_id
LEFT JOIN
    field_options AS fo
    ON dc.changed_field_key = 'lost_reason' 
    AND CASE WHEN dc.new_value ~ '^[0-9]+$' THEN cast(dc.new_value AS integer) END = fo.option_id
  );
  