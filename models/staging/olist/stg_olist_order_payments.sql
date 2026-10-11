with source as (
    select
        *
    from
        {{ source('raw', 'order_payments') }}
)

select * from source