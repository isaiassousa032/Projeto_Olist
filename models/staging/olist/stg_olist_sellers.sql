with source as (
    select
        *
    from
        {{ source('raw', 'sellers') }}
)