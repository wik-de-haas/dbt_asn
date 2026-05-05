select
    cast(storekey as int) as store_key,
    cast(country as string) as country,
    cast(state as string) as store_state,
    cast(`Square Meters` as int) as square_meters,
    cast(`Open Date` as date) as open_date
from {{ source("raw_data", "stores") }}
