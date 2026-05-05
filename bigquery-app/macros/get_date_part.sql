{#
    This macro extracts a specific part from a date or timestamp column.

    Args:
        date_part (string): The part of the date to extract (e.g., 'year', 'month', 'day').
        date_column (column): The column containing the date or timestamp.

    Returns:
        An integer representing the extracted part of the date.
#}
{% macro get_date_part(date_part, date_column) %}
    EXTRACT({{ date_part }} FROM {{ date_column }})
{% endmacro %}
