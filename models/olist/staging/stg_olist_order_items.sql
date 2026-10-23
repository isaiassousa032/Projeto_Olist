with source as (
    -- Extração dos dados da camada RAW
    select * from {{ source('raw', 'order_items') }}

),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(order_id) as order_id,
        order_item_id,
        trim(product_id) as product_id,
        trim(seller_id) as seller_id,
        shipping_limit_date,
        price,
        freight_value

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price as item_price,
        freight_value as freight_price

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        item_price,
        freight_price

    from renamed

)

select * from final