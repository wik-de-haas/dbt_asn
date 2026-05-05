-- This test fails if the model is empty.
-- It checks that the number of rows in the model is not 0.

SELECT COUNT(*) as row_count
FROM {{ ref('agg_customer_orders') }}
HAVING COUNT(*) = 0 -- This test fails (returns rows) only if the table is empty
