{{ config (
    materialized='table',
    schema='staging'
)}}

with source_data as (

    select *
    from {{ source('bron_1', 'klant') }}

)

select
    'B1|KLANT|' || klantnummer as party_id,
    naam as name,
    start_dt,
    end_dt,
    geboortedatum as birth_dt,
    klantnummer as client_number,
    technical_start_dt,
    technical_end_dt
from source_data