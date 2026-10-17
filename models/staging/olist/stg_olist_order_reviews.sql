with source as (
    
    select * from {{ source('raw', 'order_reviews') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(review_id) as review_id,
        trim(order_id) as order_id,
        review_score,
        nullif(trim(review_comment_title), '') as review_comment_title,
        nullif(trim(review_comment_message), '') as review_comment_message,
        review_creation_date,
        review_answer_timestamp

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        review_id,
        order_id,
        review_score as rating,
        review_comment_title as comment_title,
        review_comment_message as comment_message,
        review_creation_date as review_created_at,
        review_answer_timestamp as review_answered_at

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        review_id,
        order_id,
        rating,
        comment_title,
        comment_message,
        review_created_at,
        review_answered_at

    from renamed
)

select * from final