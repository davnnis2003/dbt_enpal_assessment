
SELECT
    field_id,
    field_key,
    field_name,
    cast(opt->>'id' AS integer) AS option_id,
    cast(opt->>'label' AS varchar) AS option_label
FROM
    "postgres"."staging"."stg_pipedrive_fields",
    jsonb_array_elements(field_value_options) AS opt