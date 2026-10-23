with source as (
    
    select * from {{ source('raw', 'product_category_name_translation') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        lower(trim(product_category_name)) as product_category_name,
        lower(trim(product_category_name_english)) as product_category_name_english

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        product_category_name as category_name_pt,
        product_category_name_english as category_name_en

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        category_name_pt,
        category_name_en

    from renamed
)

select * from final