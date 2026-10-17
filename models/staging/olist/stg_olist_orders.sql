with source as (
    
    select
        *
    from
        {{ source('raw', 'orders') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(order_id) as order_id,
        trim(customer_id) as customer_id,
        lower(trim(order_status)) as order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        order_id,
        customer_id,
        order_status as status,
        order_purchase_timestamp as purchased_at,
        order_approved_at as approved_at,
        order_delivered_carrier_date as delivered_to_carrier_at,
        order_delivered_customer_date as delivered_to_customer_at,
        order_estimated_delivery_date as estimated_delivery_at

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        order_id,
        customer_id,
        status,
        purchased_at,
        approved_at,
        delivered_to_carrier_at,
        delivered_to_customer_at,
        estimated_delivery_at

    from renamed
)

select * from final