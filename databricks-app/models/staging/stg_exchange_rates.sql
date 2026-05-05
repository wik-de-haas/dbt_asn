select
    cast(`Date` as date) as date,
    cast(currency as string) as currency_code,
    cast(exchange as decimal(18, 6)) as exchange_rate
from {{ source("raw_data", "exchange_rates") }}
