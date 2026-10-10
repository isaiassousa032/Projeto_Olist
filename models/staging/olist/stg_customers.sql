SELECT
    *
    FROM
        {{ source('raw', 'orders') }}
        LIMIT 10;
