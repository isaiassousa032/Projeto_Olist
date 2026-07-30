/*******************************************************************************
PROJETO: Olist Análise de  E-commerce
SCRIPT: 01_analise_recencia_churn.sql
OBJETIVO: Identificar a data da última compra por cliente único (customer_unique_id),
          calcular a recência em dias e classificar os clientes em faixas de risco de churn.
*******************************************************************************/

WITH data_referencia_base AS (
    -- Define a data do último pedido entregue como o ponto de referência temporal da base
    SELECT MAX(order_purchase_timestamp) AS max_data_base
    FROM olist.olist_orders
    WHERE order_status = 'delivered'
),

ultima_compra_cliente AS (
    -- Agrupa por cliente único para extrair a data mais recente de compra e o total de pedidos
    SELECT
        cli.customer_unique_id,
        MAX(ped.order_purchase_timestamp) AS ultima_compra,
        COUNT(DISTINCT ped.order_id) AS total_pedidos
    FROM olist.olist_orders AS ped
    INNER JOIN olist.olist_customers AS cli
        ON ped.customer_id = cli.customer_id
    WHERE ped.order_status = 'delivered'
    GROUP BY cli.customer_unique_id
),

recencia_calculada AS (
    -- Calcula a diferença em dias entre a data de referência e a última compra do cliente
    SELECT
        u.customer_unique_id,
        u.total_pedidos,
        u.ultima_compra,
        ref.max_data_base,
        (ref.max_data_base::DATE - u.ultima_compra::DATE) AS dias_recencia
    FROM ultima_compra_cliente AS u
    CROSS JOIN data_referencia_base AS ref
)

-- Resultado final com a segmentação de risco de Churn
SELECT
    customer_unique_id,
    total_pedidos,
    ultima_compra::DATE AS data_ultima_compra,
    dias_recencia,
    CASE
        WHEN dias_recencia <= 90 THEN '01. Ativo (<= 90 dias)'
        WHEN dias_recencia BETWEEN 91 AND 180 THEN '02. Em Alerta (91 a 180 dias)'
        WHEN dias_recencia BETWEEN 181 AND 360 THEN '03. Risco de Churn (181 a 360 dias)'
        ELSE '04. Churn / Inativo (> 360 dias)'
    END AS status_recencia
FROM recencia_calculada
ORDER BY dias_recencia ASC;