-- This is the final marts model.
-- It aggregates order data to the customer and year level.
select
    customer_id,
    order_year,  -- Use the column from the intermediate model
    count(order_id) as total_orders,
    sum(case when is_completed = 1 then amount_usd else 0 end) as total_revenue_usd,
    cast(min(ordered_at) as date) as first_order_date,
    cast(max(ordered_at) as date) as last_order_date

from {{ ref("int_orders") }}

group by customer_id, order_year
