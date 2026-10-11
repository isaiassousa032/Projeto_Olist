with source as (
    select
        *
    from
        {{ source('raw', 'order_reviews') }}
)

select * from source