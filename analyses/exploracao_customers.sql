SELECT
    *
FROM
    {{ source('raw', 'customers') }}
LIMIT 10;