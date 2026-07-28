# Medidas e Tabelas Calculadas em DAX — Projeto Olist

Este documento reúne todas as fórmulas DAX utilizadas na construção da dCalendario, cálculo dos KPIs operacionais, métricas de satisfação, inteligência de tempo e colunas auxiliares de geolocalização do projeto.

---

## 00. Tabela d_Calendario

Tabela dimensão de calendário criada dinamicamente com base nas datas de compra dos pedidos:

```dax
d_Calendario = 
VAR DataMinima = MIN(d_Pedidos[Data da Compra])
VAR DataMaxima = MAX(d_Pedidos[Data da Compra])
VAR AnoInicio = YEAR(DataMinima)
VAR AnoFim = YEAR(DataMaxima)

RETURN
ADDCOLUMNS(
    CALENDAR(DATE(AnoInicio, 1, 1), DATE(AnoFim, 12, 31)),
    "Data", [Date],
    "Ano", YEAR([Date]),
    "Mês (Número)", MONTH([Date]),
    "Nome do Mês", FORMAT([Date], "mmmm", "pt-BR"),
    "Mês Abreviado", FORMAT([Date], "mmm", "pt-BR"),
    "Ano-Mês Nome", FORMAT([Date], "mmm/yy", "pt-BR"),
    "Ano-Mês Classif", YEAR([Date]) * 100 + MONTH([Date]),
    "Trimestre", "T" & FORMAT([Date], "q"),
    "Dia da Semana", WEEKDAY([Date], 2),
    "Nome do Dia", FORMAT([Date], "dddd", "pt-BR")
)
```

---

## 01. Vendas & Faturamento

```dax
Faturamento Total = [Receita de Produtos] + [Receita de Frete]
```
```dax
Média de Itens Por Pedido = DIVIDE([Total de Itens Vendidos], [Total de Pedidos], 0)
```
```dax
Receita de Frete = SUM(f_Vendas[Valor do Frete])
```
```dax
Receita de Produtos = SUM(f_Vendas[Valor do Item])
```
```dax
Ticket Médio = DIVIDE([Receita de Produtos], [Total de Pedidos], 0)
```
```dax
Total de Itens Vendidos = COUNTROWS(f_Vendas)
```
```dax
Total de Pedidos = DISTINCTCOUNT(d_Pedidos[ID do Pedido])
```

---

## 02. Inteligência de Tempo

```dax
Crescimento Receita YoY % = 
VAR ReceitaAtual = [Receita de Produtos]
VAR ReceitaPassada = [Receita Produtos SPLY] 
RETURN 
DIVIDE(ReceitaAtual - ReceitaPassada, ReceitaPassada, 0)
```
```dax
Receita Produtos SPLY = CALCULATE([Receita de Produtos], SAMEPERIODLASTYEAR(d_Calendario[Data]))
```
```dax
Receita Produtos YTD = TOTALYTD([Receita de Produtos], d_Calendario[Data])
```

---

## 03. Operacional & SLA de Entrega

```dax
% Taxa de Atraso = 
DIVIDE(
    [Pedidos com Atraso na Entrega],
    [Total de Pedidos],
    0
)
```
```dax
Pedidos com Atraso na Entrega = 
CALCULATE(
    [Total de Pedidos],
    FILTER(
        d_Pedidos,
        d_Pedidos[Status do Pedido] = "delivered" &&
        d_Pedidos[Data da Entrega] > d_Pedidos[Data Estimada de Entrega]
    )
)
```
```dax
Pedidos Entregues = 
CALCULATE(
    [Total de Pedidos], 
    d_Pedidos[Status do Pedido] = "delivered", 
    USERELATIONSHIP(d_Calendario[Data], d_Pedidos[Data da Entrega])
)
```
```dax
Tempo Médio de Entrega (Dias) = 
AVERAGEX(
    FILTER(
        d_Pedidos,
        NOT ISBLANK(d_Pedidos[Data da Entrega]) && 
        NOT ISBLANK(d_Pedidos[Data da Compra])
    ),
    DATEDIFF(d_Pedidos[Data da Compra], d_Pedidos[Data da Entrega], DAY)
)
```
---

## 04. Avaliações & Satisfação

```dax
% Avaliações Promotoras (5 Estrelas) = 
DIVIDE(
    [Avaliações 5 Estrelas],
    [Total de Avaliações],
    0
)
```
```dax
% Taxa de Atraso por Categoria = 
CALCULATE(
    [% Taxa de Atraso],
    f_Vendas
)
```
```dax
Avaliações 5 Estrelas = 
CALCULATE(
    [Total de Avaliações], 
    f_Avaliacoes[Nota da Avaliação] = 5
)
```
```dax
Nota Média das Avaliações = AVERAGE(f_Avaliacoes[Nota da Avaliação])
```
```dax
Nota Média por Categoria = CALCULATE([Nota Média das Avaliações], f_Vendas)
```
```dax
Tempo Médio de Entrega por Categoria = CALCULATE([Tempo Médio de Entrega (Dias)], f_Vendas)
```
```dax
Total de Avaliações = COUNTROWS(f_Avaliacoes)
```
```dax
Total de Pedidos por Categoria = DISTINCTCOUNT(f_Vendas[ID do Pedido])
```
---

## 05. Colunas e Tabelas Calculadas

Tratamento de incompatibilidade dos nomes dos estados para renderização no mapa nativo do Power BI:
```dax
Nome Estado Mapa = 
SWITCH(
    d_Clientes[UF do Cliente],
    "AC", "Acre",
    "AL", "Alagoas",
    "AM", "Amazonas",
    "AP", "Amapa",
    "BA", "Bahia",
    "CE", "Ceara",
    "DF", "Distrito Federal",
    "ES", "Espirito Santo",
    "GO", "Goias",
    "MA", "Maranhao",
    "MG", "Minas Gerais",
    "MS", "Mato Grosso do Sul",
    "MT", "Mato Grosso",
    "PA", "Para",
    "PB", "Paraiba",
    "PE", "Pernambuco",
    "PI", "Piaui",
    "PR", "Parana",
    "RJ", "Rio de Janeiro",
    "RN", "Rio Grande do Norte",
    "RO", "Rondonia",
    "RR", "Roraima",
    "RS", "Rio Grande do Sul",
    "SC", "Santa Catarina",
    "SE", "Sergipe",
    "SP", "Sao Paulo",
    "TO", "Tocantins",
    BLANK()
)
```
```dax
UF Completa = d_Clientes[UF do Cliente] & ", Brasil"
```
---
