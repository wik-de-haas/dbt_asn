select
    customer_key,
    gender,
    first_name,
    last_name,
    city,
    state_code,
    customer_state,
    zip_code,
    country,
    continent,
    birthday,
    year(birthday) as birth_year,
    month(birthday) as birth_month,
    floor(months_between(current_date(), birthday) / 12) as age_years,
    case
        when floor(months_between(current_date(), birthday) / 12) < 25
        then '18-24'
        when floor(months_between(current_date(), birthday) / 12) < 35
        then '25-34'
        when floor(months_between(current_date(), birthday) / 12) < 45
        then '35-44'
        when floor(months_between(current_date(), birthday) / 12) < 55
        then '45-54'
        when floor(months_between(current_date(), birthday) / 12) < 65
        then '55-64'
        else '65+'
    end as age_band
from {{ ref("stg_customers") }}
