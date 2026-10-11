with source as (

    select
        *
    from
        {{ source('raw', 'geolocation') }}
)

select * from source