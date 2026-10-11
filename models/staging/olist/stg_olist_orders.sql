with source as (
    select
        *
    from
        {{ source('raw', 'orders') }}
)

select * from source