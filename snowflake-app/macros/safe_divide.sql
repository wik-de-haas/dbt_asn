{% macro safe_divide(numerator, denominator) %}
    case
        when coalesce({{ denominator }}, 0) = 0 then null
        when coalesce({{ numerator }}, 0) = 0 then null
        else {{ numerator }} / {{ denominator }}
    end
{% endmacro %}