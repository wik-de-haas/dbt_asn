{#
    This macro rounds a monetary value to 2 decimal places.

    Args:
        column_name (column): The column containing the monetary value.

    Returns:
        The amount rounded to 2 decimal places.
#}
{% macro format_currency(column_name) %}
    ROUND(CAST({{ column_name }} AS NUMERIC), 2)
{% endmacro %}
