{{ config(
    materialized='table',
    schema='intermediate'
) }}

with collateral1 as (
    select
        *
    from {{ ref('staging__collateral_1') }}
),

collateral2 as (
    select
        *
    from {{ ref('staging__collateral_2') }}
),

all_data as (
    select * from collateral1
    union all
    select * from collateral2
)

select
    *
from all_data