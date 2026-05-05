{#
    This macro extracts a specific part from a date or timestamp column.

    Args:
        part (string): The part of the date to extract (e.g., 'year', 'month', 'day').
        column (column): The column containing the date or timestamp.

    Returns:
        An integer representing the extracted part of the date.
#}
{% macro get_date_part(part, column) %}
    date_part({{ part }}, {{ column }})
{% endmacro %}
