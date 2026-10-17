with source as (
    -- Extração dos dados da camada RAW
    select * from {{ source('raw', 'customers') }}

),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        trim(customer_id) as customer_id,
        trim(customer_unique_id) as customer_unique_id,
        customer_zip_code_prefix,
        initcap(trim(customer_city)) as customer_city,
        upper(trim(customer_state)) as customer_state

    from source

),

renamed as (
    -- Renomeação das colunas
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix as zip_code,
        lower(trim(customer_city)) as city,
        upper(trim(customer_state)) as state

    from cleaned

),

final as (
    -- Seleção final das colunas
    select
        customer_id,
        customer_unique_id,
        zip_code,
        city,
        state

    from renamed
)

select * from final