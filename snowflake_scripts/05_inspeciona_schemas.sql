-- verifica nomes dos arquivos csv
LIST @OLIST.RAW.OLIST_CSV_STAGE;



-- CUSTOMERS
SELECT
    'olist_customers_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_customers_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- GEOLOCATION
SELECT
    'olist_geolocation_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_geolocation_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- ORDER ITEMS
SELECT
    'olist_order_items_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_order_items_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- ORDER PAYMENTS
SELECT
    'olist_order_payments_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_order_payments_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- ORDER REVIEWS
SELECT
    'olist_order_reviews_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_order_reviews_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- ORDERS
SELECT
    'olist_orders_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_orders_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- PRODUCTS
SELECT
    'olist_products_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_products_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- SELLERS
SELECT
    'olist_sellers_dataset.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/olist_sellers_dataset.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;


-- PRODUCT CATEGORY TRANSLATION
SELECT
    'product_category_name_translation.csv' AS source_file,
    ORDER_ID,
    COLUMN_NAME,
    TYPE,
    NULLABLE
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@OLIST.RAW.OLIST_CSV_STAGE/product_category_name_translation.csv',
        FILE_FORMAT => 'OLIST.RAW.OLIST_CSV_FORMAT'
    )
)
ORDER BY ORDER_ID;