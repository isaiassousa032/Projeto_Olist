-- Olist v2 - Estrutura fisica de referencia da camada RAW no Snowflake.
-- Fonte de verdade: snowflake_scripts/06_cria_tabelas_raw.sql.
-- Mantem os mesmos nomes, tipos e nulabilidade das nove tabelas de origem.
-- O script-fonte nao declara PK, FK, UNIQUE, NOT NULL, CHECK, IDENTITY ou indices.
-- As sete ligacoes no DrawDB sao associacoes logicas, nao constraints fisicas.
-- Arquivo de documentacao: nenhum comando foi executado durante esta revisao.

USE DATABASE OLIST;
USE SCHEMA RAW;

CREATE TABLE IF NOT EXISTS CUSTOMERS (
    customer_id VARCHAR,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR
);

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

CREATE TABLE IF NOT EXISTS ORDER_ITEMS (
    order_id VARCHAR,
    order_item_id NUMBER(38,0),
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP_NTZ,
    price NUMBER(12,2),
    freight_value NUMBER(12,2)
);

CREATE TABLE IF NOT EXISTS SELLERS (
    seller_id VARCHAR,
    seller_zip_code_prefix VARCHAR,
    seller_city VARCHAR,
    seller_state VARCHAR
);

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

CREATE TABLE IF NOT EXISTS GEOLOCATION (
    geolocation_zip_code_prefix VARCHAR,
    geolocation_lat NUMBER(38,20),
    geolocation_lng NUMBER(38,20),
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);

CREATE TABLE IF NOT EXISTS PRODUCT_CATEGORY_NAME_TRANSLATION (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);

CREATE TABLE IF NOT EXISTS ORDER_REVIEWS (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INTEGER,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP_NTZ,
    review_answer_timestamp TIMESTAMP_NTZ
);

CREATE TABLE IF NOT EXISTS ORDER_PAYMENTS (
    order_id VARCHAR,
    payment_sequential INTEGER,
    payment_type VARCHAR,
    payment_installments INTEGER,
    payment_value NUMBER(12,2)
);

-- Associacoes logicas de consulta (cardinalidade de referencia N:1):
-- ORDERS.customer_id -> CUSTOMERS.customer_id
-- ORDER_ITEMS.order_id -> ORDERS.order_id
-- ORDER_ITEMS.product_id -> PRODUCTS.product_id
-- ORDER_ITEMS.seller_id -> SELLERS.seller_id
-- ORDER_REVIEWS.order_id -> ORDERS.order_id
-- ORDER_PAYMENTS.order_id -> ORDERS.order_id
-- PRODUCTS.product_category_name -> PRODUCT_CATEGORY_NAME_TRANSLATION.product_category_name
-- A ultima associacao nao garante que toda categoria tenha traducao.
-- GEOLOCATION permanece isolada: o prefixo de CEP pode se repetir.
-- Identificadores de negocio: (order_id, order_item_id) em ORDER_ITEMS e
-- (order_id, payment_sequential) em ORDER_PAYMENTS, sem PKs fisicas no DDL-fonte.
-- ORDER_REVIEWS nao possui review_row_id; review_id pode se repetir.
