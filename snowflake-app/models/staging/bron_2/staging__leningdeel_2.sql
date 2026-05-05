{{ config(materialized='table', schema='staging')}}

with source_data as (

    select *
    from {{ source('bron_2', 'leningdeel') }}

)

select
    'B1|LOAN|' || leningnummer as loan_agreement_id,
    'B1|HOOFDSOM|' || leningnummer || '|' || leningdeelnummer as loan_part_agreement_id,
    leningnummer as loan_number,
    leningdeelnummer as loan_part_number,
    start_dt,
    end_dt,
    product_id,
    saldo as outstanding_nominal_amt,
    oorspronkelijke_hoofdsom as original_loan_amt,
    technical_start_dt,
    technical_end_dt
from source_data