select
    review_id,
    order_id,
    rating,
    comment_title,
    comment_message,
    review_created_at,
    review_answered_at
from {{ ref('stg_olist_order_reviews') }}
