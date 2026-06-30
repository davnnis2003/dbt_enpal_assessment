SELECT
    fct_crm_deal_changes.deal_change_id AS deal_change_id,
    fct_crm_deal_changes.deal_id AS deal_id,
    fct_crm_deal_changes.deal_created_at_utc AS deal_created_at_utc,
    fct_crm_deal_changes.deal_created_at_berlin AS deal_created_at_berlin,
    fct_crm_deal_changes.changed_at_utc AS changed_at_utc,
    fct_crm_deal_changes.changed_at_berlin AS changed_at_berlin,
    fct_crm_deal_changes.changed_field_key AS changed_field_key,
    fct_crm_deal_changes.field_name AS field_name,
    fct_crm_deal_changes.old_value AS old_value,
    fct_crm_deal_changes.new_value AS new_value,
    fct_crm_deal_changes.old_value_resolved AS old_value_resolved,
    fct_crm_deal_changes.new_value_resolved AS new_value_resolved
FROM {{ ref('mart__fct_crm_deal_changes') }} AS fct_crm_deal_changes
WHERE
    1 = 1
    AND fct_crm_deal_changes.deal_id = 155164
ORDER BY
    fct_crm_deal_changes.changed_at_utc ASC
