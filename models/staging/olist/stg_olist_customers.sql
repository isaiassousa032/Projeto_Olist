with source as (

    select
        *
    from
        {{ source('raw', 'customers') }}
)

select * from source
