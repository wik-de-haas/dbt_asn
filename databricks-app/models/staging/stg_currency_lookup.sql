select
    cast(currencycode as string) as currency_code,
    cast(currencyname as string) as currency_name,
    cast(currencysymbol as string) as currency_symbol,
    cast(region as string) as region
from {{ ref("Currency_Lookup") }}
