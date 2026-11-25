with source as (
    -- Extração dos dados da camada RAW
    select *
    from {{ source('raw', 'geolocation') }}
),

cleaned as (
    -- Limpeza e padronização dos dados
    select
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        initcap(trim(geolocation_city)) as geolocation_city,
        upper(trim(geolocation_state)) as geolocation_state

    from source
),

renamed as (
    -- Renomeação das colunas
    select
        geolocation_zip_code_prefix as zip_code_prefix,
        geolocation_lat as latitude,
        geolocation_lng as longitude,
        geolocation_city as city,
        geolocation_state as state

    from cleaned
),

final as (
    -- Seleção final das colunas
    select
        zip_code_prefix,
        latitude,
        longitude,
        city,
        state

    from renamed
)

select * from final