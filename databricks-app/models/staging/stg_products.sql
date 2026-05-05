select
    cast(productkey as int) as product_key,
    cast(`Product Name` as string) as product_name,
    cast(brand as string) as brand,
    cast(color as string) as color,
    cast(
        trim(replace(replace(`Unit Cost USD`, '$', ''), ',', '')) as decimal(18, 2)
    ) as unit_cost_usd,
    cast(
        trim(replace(replace(`Unit Price USD`, '$', ''), ',', '')) as decimal(18, 2)
    ) as unit_price_usd,
    cast(subcategorykey as int) as subcategory_key,
    cast(subcategory as string) as subcategory,
    cast(categorykey as int) as category_key,
    cast(category as string) as category
from {{ source("raw_data", "products") }}
