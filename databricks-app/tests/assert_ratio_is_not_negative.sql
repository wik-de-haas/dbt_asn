-- This is a singular test. It will pass if this query returns 0 rows.
-- Our business rule: The total revenue should never be negative.
-- Therefore, this query looks for any records that violate this rule.

SELECT
    customer_key,
    revenue_usd
FROM
    {{ ref('fct_sales') }}
WHERE
    revenue_usd < 0
