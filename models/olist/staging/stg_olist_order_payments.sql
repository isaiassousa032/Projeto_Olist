with source as (
    -- Extração dos dados da camada RAW
    select * from {{ source('raw', 'order_payments') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(order_id) as order_id,
        payment_installments,
        payment_sequential,
        lower(trim(payment_type)) as payment_type,
        payment_value

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        order_id,
        payment_installments as installments_count,
        payment_sequential,
        payment_type,
        payment_value as payment_amount

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        order_id,
        installments_count,
        payment_sequential,
        payment_type,
        payment_amount

    from renamed
)

select * from final