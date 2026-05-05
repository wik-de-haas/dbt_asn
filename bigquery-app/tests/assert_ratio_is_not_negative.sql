-- This is a singular test. It will pass if this query returns 0 rows.
-- Our business rule: The total revenue should never be negative.
-- Therefore, this query looks for any records that violate this rule.

SELECT
    customer_id,
    total_revenue_usd
FROM
    {{ ref('agg_customer_orders') }}
WHERE
    total_revenue_usd < 0
