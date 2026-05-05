{{ config(
    materialized='table',
    schema='marts'
) }}

with total_market as (
    select
        loan_agreement_id,
        total_market_value
    from {{ ref('int__total_market_value') }}
),

loan_part as (
    select
        loan_part_agreement_id,
        loan_agreement_id,
        outstanding_nominal_amt
    from {{ ref('int__loan_part_agreement') }}
),

total_outstanding as (
    select
        loan_agreement_id,
        total_outstanding_loan_amt
    from {{ ref('int__total_outstanding_loan_amt') }}
),

cte as (
    select
        lp.loan_part_agreement_id,
        lp.loan_agreement_id,
        lp.outstanding_nominal_amt,
        too.total_outstanding_loan_amt,
        tm.total_market_value
    from loan_part lp
    left join total_outstanding too
        on lp.loan_agreement_id = too.loan_agreement_id
    left join total_market tm
        on lp.loan_agreement_id = tm.loan_agreement_id
)

select
    loan_part_agreement_id,
    outstanding_nominal_amt,
    loan_agreement_id,
    total_outstanding_loan_amt,
    total_market_value,

    case
        when coalesce(total_market_value, 0) = 0 then null
        else {{ safe_divide('outstanding_nominal_amt', 'total_outstanding_loan_amt') }} * total_market_value
    end as collateral_value_amt,

    case
        when coalesce(total_market_value, 0) = 0 then null
        else {{ safe_divide('total_outstanding_loan_amt', 'total_market_value') }}
    end as loan_to_value_rate

from cte