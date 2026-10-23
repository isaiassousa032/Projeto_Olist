select
    zip_code_prefix,
    city,
    state,
    avg(latitude) as latitude,
    avg(longitude) as longitude,
    count(*) as location_count
from {{ ref('stg_olist_geolocation') }}
group by zip_code_prefix, city, state
qualify row_number() over (
    partition by zip_code_prefix
    order by count(*) desc, state, city
) = 1
