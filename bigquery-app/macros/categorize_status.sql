{#
    This macro categorizes order statuses into broader groups.

    Args:
        status_column (column): The column containing the order status.

    Returns:
        A string with the category ('Completed', 'In Progress', 'Returned').
#}
{% macro categorize_status(status_column) %}
    CASE
        WHEN {{ status_column }} = 'completed' THEN 'Completed'
        WHEN {{ status_column }} = 'shipped' THEN 'In Progress'
        WHEN {{ status_column }} = 'returned' THEN 'Returned'
        ELSE 'Unknown'
    END
{% endmacro %}
