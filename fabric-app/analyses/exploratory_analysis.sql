-- This is an example analysis.
-- It calculates the average total revenue per customer from our final marts model.

SELECT
    AVG(total_revenue_usd) as average_revenue_per_customer
FROM {{ ref('fct_customer_orders') }}
