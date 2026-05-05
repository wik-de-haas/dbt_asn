-- This model reads from the seed data and performs basic cleaning and casting.
-- It's the first step in our transformation pipeline.
select
    -- IDs
    cast(order_id as int64) as order_id,
    cast(customer_id as int64) as customer_id,

    -- Timestamps
    cast(order_date as date) as order_date,
    -- BigQuery uses DATETIME or TIMESTAMP, not DATETIME2
    cast(ordered_at as datetime) as ordered_at,

    -- Other columns
    cast(status as string) as status,
    -- Replace NULL amounts with 0 to ensure data quality downstream
    coalesce(cast(amount_usd as numeric), 0) as amount_usd

from {{ ref("orders") }}
