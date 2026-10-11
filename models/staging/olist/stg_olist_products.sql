with source as (
    select
        *
    from
        {{ source('raw', 'products') }}
)

select * from source