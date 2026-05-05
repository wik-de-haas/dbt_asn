select
    store_key,
    country,
    store_state,
    square_meters,
    open_date,
    case
        when country = 'Online'
        then 'Digital'
        when country in ('United States', 'Canada')
        then 'North America'
        when country in ('Netherlands', 'Italy', 'Germany', 'France', 'United Kingdom')
        then 'Europe'
        when country = 'Australia'
        then 'APAC'
        else 'Other'
    end as region,
    case when country = 'Online' then 'Online' else 'Physical' end as channel
from {{ ref("stg_stores") }}
