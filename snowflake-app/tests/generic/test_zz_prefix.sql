-- tests/generic/test_zz_prefix.sql
{% test zz_prefix(model, column_name) %}
SELECT 
    *
FROM {{ model }}
WHERE {{ column_name }} NOT LIKE 'zz_%'
{% endtest %}