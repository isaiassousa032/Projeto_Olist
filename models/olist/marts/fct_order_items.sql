select
    items.order_id || '-' || to_varchar(items.order_item_id) as order_item_key,
    items.order_id,
    items.order_item_id,
    orders.customer_id,
    orders.purchased_at,
    items.product_id,
    items.seller_id,
    items.shipping_limit_date,
    items.item_price,
    items.freight_price
from {{ ref('stg_olist_order_items') }} as items
left join {{ ref('stg_olist_orders') }} as orders
    on items.order_id = orders.order_id
