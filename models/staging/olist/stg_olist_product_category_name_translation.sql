with source as (
    select
        *
    from
        {{ source('raw', 'product_category_name_translation') }}
)

select * from source