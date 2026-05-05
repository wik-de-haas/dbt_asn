{{ config(
    materialized='table',
    schema='intermediate'
) }}

with collateral as (
    select
        loan_agreement_id,
        market_value
    from {{ ref('int__collateral') }}
)

select
    loan_agreement_id,
    sum(market_value) as total_market_value
from collateral
group by loan_agreement_id