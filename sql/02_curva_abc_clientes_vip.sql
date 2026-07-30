/*******************************************************************************
PROJETO: Olist Análise de E-commerce
SCRIPT: 02_curva_abc_clientes_vip.sql
OBJETIVO: Identificar os clientes VIPs (Top 5%) e classificar a base inteira
          na Curva ABC com base na receita acumulada gerada por cliente único.
*******************************************************************************/

WITH receita_por_cliente AS (
    -- Agrupa o faturamento de produtos e total de pedidos por cliente único
    SELECT
        cli.customer_unique_id,
        COUNT(DISTINCT ped.order_id) AS total_pedidos,
        SUM(ite.price) AS faturamento_produtos
    FROM olist.olist_orders AS ped
    INNER JOIN olist.olist_customers AS cli
        ON ped.customer_id = cli.customer_id
    INNER JOIN olist.olist_order_items AS ite
        ON ped.order_id = ite.order_id
    WHERE ped.order_status = 'delivered'
    GROUP BY cli.customer_unique_id
),

faturamento_acumulado AS (
    -- Aplica Window Functions para calcular a receita running total e o percentil dos clientes
    SELECT
        customer_unique_id,
        total_pedidos,
        faturamento_produtos,
        SUM(faturamento_produtos) OVER () AS faturamento_geral_base,
        SUM(faturamento_produtos) OVER (
            ORDER BY faturamento_produtos DESC, customer_unique_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS faturamento_acumulado_running,
        PERCENT_RANK() OVER (
            ORDER BY faturamento_produtos DESC
        ) AS percentil_cliente
    FROM receita_por_cliente
),

classificacao_abc_vip AS (
    -- Define as faixas da Curva ABC e categoriza a flag de Cliente VIP (Top 5%)
    SELECT
        customer_unique_id,
        total_pedidos,
        faturamento_produtos,
        ROUND((percentil_cliente * 100)::NUMERIC, 2) AS percentil_ranking,
        ROUND(((faturamento_acumulado_running / faturamento_geral_base) * 100)::NUMERIC, 2) AS pct_faturamento_acumulado,
        CASE
            WHEN (faturamento_acumulado_running / faturamento_geral_base) <= 0.80 THEN 'Classe A (Até 80% da Receita)'
            WHEN (faturamento_acumulado_running / faturamento_geral_base) <= 0.95 THEN 'Classe B (80% a 95% da Receita)'
            ELSE 'Classe C (95% a 100% da Receita)'
        END AS classe_abc,
        CASE
            WHEN percentil_cliente <= 0.05 THEN 'Sim'
            ELSE 'Não'
        END AS is_cliente_vip_top5pct
    FROM faturamento_acumulado
)

-- Resultado final ordenado pelos maiores geradores de receita
SELECT
    customer_unique_id,
    total_pedidos,
    faturamento_produtos,
    percentil_ranking,
    pct_faturamento_acumulado,
    classe_abc,
    is_cliente_vip_top5pct
FROM classificacao_abc_vip
ORDER BY faturamento_produtos DESC;