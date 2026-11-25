with source as (
    select * from {{ source('raw', 'products') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(product_id) as product_id,
        lower(trim(product_category_name)) as product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        product_id,
        product_category_name as category_name_pt,
        product_name_lenght as name_length,
        product_description_lenght as description_length,
        product_photos_qty as photos_count,
        product_weight_g as weight_g,
        product_length_cm as length_cm,
        product_height_cm as height_cm,
        product_width_cm as width_cm

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        product_id,
        category_name_pt,
        name_length,
        description_length,
        photos_count,
        weight_g,
        length_cm,
        height_cm,
        width_cm

    from renamed
)

select * from final