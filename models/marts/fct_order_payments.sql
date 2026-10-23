select
    payments.order_id || '-' || to_varchar(payments.payment_sequential) as order_payment_key,
    payments.order_id,
    payments.payment_sequential,
    orders.purchased_at,
    payments.payment_type,
    payments.installments_count,
    payments.payment_amount
from {{ ref('stg_olist_order_payments') }} as payments
left join {{ ref('stg_olist_orders') }} as orders
    on payments.order_id = orders.order_id
