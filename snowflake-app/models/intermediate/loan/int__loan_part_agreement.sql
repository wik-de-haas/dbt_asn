{{ config(
    materialized='table',
    schema='intermediate'
) }}

with loan1 as (
    select
        *
    from {{ ref('staging__leningdeel_1') }}
),

loan2 as (
    select
        *
    from {{ ref('staging__leningdeel_2') }}
),

all_data as (
    select * from loan1
    union all
    select * from loan2
)

select
    *
from all_data