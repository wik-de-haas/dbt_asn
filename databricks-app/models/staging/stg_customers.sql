select
    cast(customerkey as int) as customer_key,
    cast(gender as string) as gender,
    split_part(name, ' ', 1) as first_name,
    split_part(name, ' ', 2) as last_name,
    cast(city as string) as city,
    cast(`State Code` as string) as state_code,
    cast(state as string) as customer_state,
    cast(`Zip Code` as string) as zip_code,
    cast(country as string) as country,
    cast(continent as string) as continent,
    to_date(cast(birthday as string), 'yyyy-MM-dd') as birthday
from {{ source("raw_data", "customers") }}
