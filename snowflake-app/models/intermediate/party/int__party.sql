{{ config(
    materialized='table',
    schema='intermediate'
) }}

with party1 as (
    select
        *
    from {{ ref('staging__party_1') }}
),

party2 as (
    select
        *
    from {{ ref('staging__party_2') }}
),

all_data as (
    select * from party1
    union all
    select * from party2
)

select
    *
from all_data