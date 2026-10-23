select
    products.product_id,
    products.category_name_pt,
    translations.category_name_en,
    products.name_length,
    products.description_length,
    products.photos_count,
    products.weight_g,
    products.length_cm,
    products.height_cm,
    products.width_cm
from {{ ref('stg_olist_products') }} as products
left join {{ ref('stg_olist_product_category_name_translation') }} as translations
    on products.category_name_pt = translations.category_name_pt
