/*******************************************************************************
PROJETO: Olist Análise de E-commerc
SCRIPT: 03_analise_cohort_retencao.sql
OBJETIVO: Construir uma matriz de Cohort para mensurar a retenção e recompra
          dos clientes ao longo dos meses após a primeira compra na Olist.
*******************************************************************************/

WITH primeira_compra AS (
    -- Identifica o mês do primeiro pedido entregue de cada cliente único (Mês do Cohort)
    SELECT
        cli.customer_unique_id,
        MIN(DATE_TRUNC('month', ped.order_purchase_timestamp)) AS mes_cohort
    FROM olist.olist_orders AS ped
    INNER JOIN olist.olist_customers AS cli
        ON ped.customer_id = cli.customer_id
    WHERE ped.order_status = 'delivered'
    GROUP BY cli.customer_unique_id
),

todas_compras_mes AS (
    -- Extrai todos os meses únicos em que cada cliente realizou pedidos
    SELECT DISTINCT
        cli.customer_unique_id,
        DATE_TRUNC('month', ped.order_purchase_timestamp) AS mes_atividade
    FROM olist.olist_orders AS ped
    INNER JOIN olist.olist_customers AS cli
        ON ped.customer_id = cli.customer_id
    WHERE ped.order_status = 'delivered'
),

cohort_calculado AS (
    -- Cruzamento entre o cohort do cliente e os meses de atividade para calcular a distância (Mês Index)
    SELECT
        tc.customer_unique_id,
        pc.mes_cohort,
        tc.mes_atividade,
        (
            (EXTRACT(YEAR FROM tc.mes_atividade) - EXTRACT(YEAR FROM pc.mes_cohort)) * 12 +
            (EXTRACT(MONTH FROM tc.mes_atividade) - EXTRACT(MONTH FROM pc.mes_cohort))
        ) AS cohort_index
    FROM todas_compras_mes AS tc
    INNER JOIN primeira_compra AS pc
        ON tc.customer_unique_id = pc.customer_unique_id
)

-- Agrupamento final exibindo a quantidade de clientes por Safra e Mês Relativo
SELECT
    TO_CHAR(mes_cohort, 'YYYY-MM') AS safra_cohort,
    cohort_index AS mes_relativo,
    COUNT(DISTINCT customer_unique_id) AS total_clientes_ativos
FROM cohort_calculado
WHERE cohort_index <= 12 -- Limita a janela de observação aos primeiros 12 meses
GROUP BY mes_cohort, cohort_index
ORDER BY mes_cohort ASC, cohort_index ASC;