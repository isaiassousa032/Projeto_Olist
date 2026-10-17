with source as (
    select * from
        {{ source('raw', 'sellers') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(seller_id) as seller_id,
        trim(seller_zip_code_prefix) as seller_zip_code_prefix,
        initcap(trim(seller_city)) as seller_city,
        upper(trim(seller_state)) as seller_state

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        seller_id,
        seller_zip_code_prefix as zip_code_prefix,
        seller_city as city,
        seller_state as state

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        seller_id,
        zip_code_prefix,
        city,
        state

    from renamed
)

select * from final