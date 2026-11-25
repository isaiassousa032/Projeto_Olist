with source as (
    SELECT
        *
    FROM
        {{ source('raw', 'customers') }}
)

SELECT * FROM source
