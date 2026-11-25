select
    order_id,
    customer_id,
    status,
    purchased_at,
    approved_at,
    delivered_to_carrier_at,
    delivered_to_customer_at,
    estimated_delivery_at
from {{ ref('stg_olist_orders') }}
