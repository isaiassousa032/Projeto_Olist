-- ========================================================
-- Cria o File Format com as configurações dos arquivos csv
-- ========================================================

-- Mostra os arquivos que estão no STAGE
LIST @OLIST.RAW.OLIST_CSV_STAGE;

-- Cria o File Format
CREATE FILE FORMAT IF NOT EXISTS OLIST.RAW.OLIST_CSV_FORMAT
    TYPE = CSV
    PARSE_HEADER = TRUE
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    EMPTY_FIELD_AS_NULL = TRUE
    NULL_IF = ('', 'NULL', 'null')
    COMPRESSION = AUTO;


SHOW FILE FORMATS IN SCHEMA OLIST.RAW;

DESCRIBE FILE FORMAT OLIST.RAW.OLIST_CSV_FORMAT;