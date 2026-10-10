-- =========================================
-- Cria o Stage para guardar os arquivos csv
-- =========================================


-- Acesso
USE ROLE ACCOUNTADMIN;
USE DATABASE OLIST;
USE SCHEMA RAW;

-- Cria o Stage para guardar os arquivos CSV
CREATE STAGE IF NOT EXISTS OLIST_CSV_STAGE
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

-- mostra os arquivos que estão no STAGE
LIST @OLIST.RAW.OLIST_CSV_STAGE;