{{ config(
    materialized='table',
    schema='intermediate'
) }}

with leningdeel as (
    select
        loan_agreement_id,
        outstanding_nominal_amt
    from {{ ref('int__loan_part_agreement') }}
)


select
    loan_agreement_id,
    sum(outstanding_nominal_amt) as total_outstanding_loan_amt
from leningdeel
group by loan_agreement_id