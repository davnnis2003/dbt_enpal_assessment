{% macro get_incremental_date_filter(column_expression, target_column_name) %}
    {{ column_expression }} >= (SELECT MAX({{ target_column_name }}) FROM {{ this }})
{% endmacro %}
