USE ROLE ACCOUNTADMIN;
USE DATABASE OLIST;
USE SCHEMA RAW;


-- Cria a tabela CUSTOMERS
CREATE TABLE IF NOT EXISTS CUSTOMERS (
    customer_id VARCHAR,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR
);
--
DESCRIBE TABLE CUSTOMERS;


-- Cria a tabela ORDERS
CREATE TABLE IF NOT EXISTS ORDERS (
    order_id VARCHAR,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP_NTZ,
    order_approved_at TIMESTAMP_NTZ,
    order_delivered_carrier_date TIMESTAMP_NTZ,
    order_delivered_customer_date TIMESTAMP_NTZ,
    order_estimated_delivery_date TIMESTAMP_NTZ
);
--
DESCRIBE TABLE ORDERS;


-- Cria a tabela ORDER_ITEMS
CREATE TABLE IF NOT EXISTS ORDER_ITEMS (
    order_id VARCHAR,
    order_item_id NUMBER(38,0),
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP_NTZ,
    price NUMBER(12,2),
    freight_value NUMBER(12,2)
);
--
DESCRIBE TABLE ORDER_ITEMS;


-- Cria a tabela SELLERS
CREATE TABLE IF NOT EXISTS SELLERS (
    seller_id VARCHAR,
    seller_zip_code_prefix VARCHAR,
    seller_city VARCHAR,
    seller_state VARCHAR
);
--
DESCRIBE TABLE SELLERS;


-- Cria a tabela PRODUCTS
CREATE TABLE IF NOT EXISTS PRODUCTS (
    product_id VARCHAR,
    product_category_name VARCHAR,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);
--
DESCRIBE TABLE PRODUCTS;


-- Cria a tabela GEOLOCATION
CREATE TABLE IF NOT EXISTS GEOLOCATION (
    geolocation_zip_code_prefix VARCHAR,
    geolocation_lat NUMBER(38,20),
    geolocation_lng NUMBER(38,20),
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);
--
DESCRIBE TABLE GEOLOCATION;


-- Cria a tabela PRODUCT_CATEGORY_NAME_TRANSLATION
CREATE TABLE IF NOT EXISTS PRODUCT_CATEGORY_NAME_TRANSLATION (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);
--
DESCRIBE TABLE PRODUCT_CATEGORY_NAME_TRANSLATION;


-- Cria a tabela ORDER_REVIEWS
CREATE TABLE IF NOT EXISTS ORDER_REVIEWS (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INTEGER,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP_NTZ,
    review_answer_timestamp TIMESTAMP_NTZ
);
--
DESCRIBE TABLE ORDER_REVIEWS;


-- Cria a tabela ORDER_PAYMENTS
CREATE TABLE IF NOT EXISTS ORDER_PAYMENTS (
    order_id VARCHAR,
    payment_sequential INTEGER,
    payment_type VARCHAR,
    payment_installments INTEGER,
    payment_value NUMBER(12,2)
);
--
DESCRIBE TABLE ORDER_PAYMENTS;



SHOW TABLES IN SCHEMA OLIST.RAW;