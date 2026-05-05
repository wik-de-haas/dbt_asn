-- This model reads from the seed data and performs basic cleaning and casting.
-- It's the first step in our transformation pipeline.
select
    -- IDs
    cast(order_id as int) as order_id,
    cast(customer_id as int) as customer_id,

    -- Timestamps
    cast(order_date as date) as order_date,
    -- Using DATETIME2 for Fabric/SQL Server compatibility
    cast(ordered_at as datetime2) as ordered_at,

    -- Other columns
    cast(status as varchar(20)) as status,
    -- Replace NULL amounts with 0 to ensure data quality downstream
    coalesce(cast(amount_usd as decimal(18, 2)), 0) as amount_usd

from {{ ref("orders") }}
