{{ config(materialized='table', schema='staging') }}

with source_data as (

    select *
    from {{ source('bron_2', 'onderpand') }}

)

select
    'B1|COLLATERAL|' || bag_id as collateral_id,
    'B1|LOAN|' || leningnummer as loan_agreement_id,
    leningnummer as loan_number,
    waarderingsdatum as valuation_dt,
    start_dt,
    end_dt,
    marktwaarde as market_value,
    stad as city,
    postcode as postal_code,
    straat as street,
    huisnummer as house_number,
    land as country,
    bag_id,
    technical_start_dt,
    technical_end_dt
from source_data