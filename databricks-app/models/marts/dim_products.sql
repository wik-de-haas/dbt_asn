select
    product_key,
    product_name,
    brand,
    color,
    unit_cost_usd,
    unit_price_usd,
    unit_price_usd - unit_cost_usd as unit_margin_usd,
    case
        when unit_cost_usd = 0 then null else (unit_price_usd - unit_cost_usd) / unit_cost_usd
    end as unit_margin_pct,
    subcategory_key,
    subcategory,
    category_key,
    category
from {{ ref("stg_products") }}
