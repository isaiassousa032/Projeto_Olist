with source as (

    select 
        *
    from 
        {{ source('raw', 'order_items') }}

)

select * from source