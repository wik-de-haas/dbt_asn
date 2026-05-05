{% snapshot orders_snapshot %}

{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='order_id',
        check_cols=['status', 'amount_usd'],
    )
}}

-- This query defines the table we want to snapshot.
SELECT
    order_id,
    customer_id,
    order_date,
    CAST(ordered_at AS DATETIME2(3)) AS ordered_at,
    status,
    amount_usd
FROM {{ ref('stg_orders') }}


{% endsnapshot %}
