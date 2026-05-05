with
    date_spine as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="cast('2015-01-01' as date)",
                end_date="cast('2022-12-31' as date)",
            )
        }}
    ),
    final as (
        select
            date_day,
            year(date_day) as year,
            month(date_day) as month,
            quarter(date_day) as quarter,
            day(date_day) as day,
            dayofweek(date_day) as day_of_week,
            case when dayofweek(date_day) in (1, 7) then true else false end as is_weekend,
            case
                when dayofweek(date_day) between 2 and 6 then true else false
            end as is_business_day,
            date_format(date_day, 'EEEE') as day_name
        from date_spine
    )
select *
from final
