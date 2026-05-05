select
    cast(`Order Number` as int) as order_number,
    cast(`Line Item` as int) as line_item,
    cast(`Order Date` as date) as order_date,
    cast(`Delivery Date` as date) as delivery_date,
    cast(customerkey as int) as customer_key,
    case when cast(storekey as int) = 0 then null else cast(storekey as int) end as store_key,
    cast(productkey as int) as product_key,
    cast(quantity as int) as quantity,
    cast(`Currency Code` as string) as currency_code
from {{ source("raw_data", "sales") }}
