select
    s.order_number,
    s.line_item,
    s.order_date,
    s.delivery_date,
    month(s.order_date) as order_month,
    year(s.order_date) as order_year,
    s.customer_key,
    s.store_key,
    s.product_key,
    s.currency_code,
    e.exchange_rate,
    s.quantity,
    s.quantity * p.unit_cost_usd as cost_usd,
    s.quantity * p.unit_price_usd as revenue_usd,
    s.quantity * p.unit_price_usd - s.quantity * p.unit_cost_usd as margin_usd,
    case
        when s.quantity * p.unit_cost_usd = 0
        then null
        else
            (s.quantity * p.unit_price_usd - s.quantity * p.unit_cost_usd)
            / (s.quantity * p.unit_cost_usd)
    end as margin_pct,
    case when s.delivery_date is not null then true else false end as is_delivered
from {{ ref("stg_sales") }} as s
left join {{ ref("stg_products") }} as p on s.product_key = p.product_key
left join {{ ref("stg_stores") }} as st on s.store_key = st.store_key
left join
    {{ ref("stg_exchange_rates") }} as e
    on s.order_date = e.date
    and s.currency_code = e.currency_code
