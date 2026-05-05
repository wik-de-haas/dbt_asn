-- This model enriches the staging data with business logic.
-- It uses CTEs to logically separate the steps of the transformation.
with
    source_orders as (select * from {{ ref("stg_orders") }}),

    enriched as (

        select
            -- Pass through all identifiers and timestamps
            order_id,
            customer_id,
            order_date,
            ordered_at,

            -- Clean and enrich other columns
            status,
            {{ format_currency("amount_usd") }} as amount_usd,  -- Overwrite with rounded amount
            {{ categorize_status("status") }} as status_category,
            {{ get_date_part("year", "ordered_at") }} as order_year,
            case when status = 'completed' then 1 else 0 end as is_completed

        from source_orders

    )

select *
from enriched
