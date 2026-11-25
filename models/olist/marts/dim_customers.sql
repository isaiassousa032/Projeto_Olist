select
    customer_id,
    customer_unique_id,
    zip_code,
    city,
    state
from {{ ref('int_olist_customers') }}
