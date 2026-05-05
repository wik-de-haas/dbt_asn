-- This test fails if the model is empty.
-- It checks that the number of rows in the model is not 0.

SELECT 1 as row_count -- select a dummy value
FROM {{ ref('fct_customer_orders') }}
HAVING NOT COUNT(*) > 0 -- fail if the count is not greater than 0
