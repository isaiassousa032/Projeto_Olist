# Insights de negócio — Olist V2

## Escopo e método

As sete análises antes pendentes foram executadas em **23/10/2026**, por consulta
DAX somente leitura no modelo **Import** aberto no Power BI Desktop
(`Olist_Analytics_v2`). A exportação contém **796 linhas** e abrange compras
entre **04/09/2016 e 17/10/2018**. Não foi acionado refresh nem executada consulta
no Snowflake; estes resultados descrevem o snapshot já carregado. A data da
última atualização desse snapshot não foi obtida.

As contagens de controle coincidiram com as já documentadas: 99.441 pedidos,
112.650 itens, 103.886 pagamentos e 99.224 avaliações. Totais por mês, categoria
e UF foram reconciliados com os totais globais, respeitando quais métricas são
aditivas. Pedidos distintos por categoria/vendedor não devem ser somados.

O **modelo dimensional é híbrido**, com dimensões e fatos organizados em
cabeçalho e detalhes: `fct_orders`, no grão de pedido, se relaciona em **1:N**
com `fct_order_items`, `fct_order_payments` e `fct_order_reviews`. Essas ligações
entre fatos preservam os grãos de cada processo. Ao combinar suas medidas em
uma consulta por pedido, cada fato de detalhe deve ser agregado separadamente
por `order_id` antes da união dos resultados.

Evidências:

- [Consulta de controle](../analyses/powerbi_validacao/00_controle.dax) e [resultado](../analyses/powerbi_validacao/00_controle.tsv).
- [Consulta DAX das sete análises](../analyses/powerbi_validacao/01_consultas_pendentes.dax).
- [Exportação integral](../analyses/powerbi_validacao/01_resultados.tsv).
- [Resultados estruturados](../analyses/powerbi_validacao/resultados_estruturados.json).
- [Conferência reproduzível](../analyses/powerbi_validacao/validacao_insights.ipynb).

Os recortes comerciais principais incluem **todos os status**; quando se usa
apenas `delivered`, isso é indicado. O calendário usa a **data da compra**.
2016 e 2018 são incompletos. Valor dos itens, frete e pagamentos são conceitos
diferentes; os resultados não redefinem receita líquida. As seções iniciais
abaixo preservam também reconciliações anteriores do projeto e suas fontes.

## Insights verificados

### 1. A base preserva os grãos necessários para análise

- **Pergunta de negócio:** podemos confiar na base dimensional para contar
  pedidos, itens, pagamentos e avaliações sem duplicação estrutural?
- **Resultado quantitativo:** há 99.441 pedidos, 112.650 itens, 103.886
  pagamentos e 99.224 avaliações. As chaves compostas
  `(order_id, order_item_id)` e `(order_id, payment_sequential)` são únicas.
  Os marts preservam as mesmas quantidades da origem e não há órfãos nas
  referências obrigatórias.
- **Interpretação:** os fatos estão coerentes com seus grãos declarados. Uma
  avaliação pode repetir `review_id`, e um pedido pode ter mais de uma linha de
  pagamento ou avaliação.
- **Possível implicação:** indicadores por pedido devem usar contagem distinta
  de `order_id`; indicadores de item, pagamento e avaliação devem usar o grão
  correspondente.
- **Fonte/consulta:** reconciliação documentada no README, baseada nas
  contagens e verificações de unicidade de
  [`07_carga_tabelas_raw.sql`](../snowflake_scripts/07_carga_tabelas_raw.sql),
  nos marts e na execução local da suíte de testes dbt.

### 2. Preços, frete e pagamentos não são intercambiáveis

- **Pergunta de negócio:** o valor dos itens pode ser tratado como receita ou
  reconciliado automaticamente com pagamentos?
- **Resultado quantitativo:** preço dos itens soma R$ 13.591.643,70; frete,
  R$ 2.251.909,54; pagamentos, R$ 16.008.872,12. A soma de pagamentos excede
  itens mais frete em R$ 165.318,88. Entre 98.665 pedidos com ambos os fatos,
  98.089 têm totais iguais e 576 têm diferenças; há ainda 775 pedidos somente
  com pagamento e 1 somente com item.
- **Interpretação:** os fatos representam eventos financeiros diferentes. A
  divergência pode refletir regras de negócio ou composição de valores que não
  estão definidas no projeto.
- **Possível implicação:** o dashboard deve nomear as métricas como “Valor dos
  Itens”, “Frete” e “Valor dos Pagamentos”, e não como faturamento ou receita
  líquida. Uma definição financeira aprovada é necessária antes de publicar
  receita, margem ou ticket financeiro.
- **Fonte/consulta:** reconciliação por `order_id` documentada no README,
  comparando agregações separadas dos modelos
  `fct_order_items` e `fct_order_payments`.

### 3. Clientes compradores se repetem na base de pedidos

- **Pergunta de negócio:** `customer_id` representa comprador único?
- **Resultado quantitativo:** `customer_unique_id` possui 96.096 valores
  distintos em 99.441 registros de clientes; portanto, há 3.345 registros
  além da cardinalidade de compradores únicos (aproximadamente 3,36% das
  linhas da dimensão).
- **Interpretação:** `customer_id` identifica o cadastro associado ao pedido,
  enquanto `customer_unique_id` aproxima a identidade do comprador entre
  pedidos. Eles não devem ser usados como sinônimos.
- **Possível implicação:** retenção, recompra e clientes únicos devem ser
  calculados por `customer_unique_id`; cobertura operacional do pedido pode
  usar `customer_id`.
- **Fonte/consulta:** reconciliação de cardinalidade registrada no README e
  descrição de [`marts_schema.yml`](../models/olist/marts/marts_schema.yml).

### 4. Há cobertura geográfica alta, mas não completa

- **Pergunta de negócio:** os prefixos de CEP dos clientes e vendedores podem
  ser enriquecidos integralmente pela dimensão geográfica?
- **Resultado quantitativo:** `dim_geography` contém 19.015 prefixos. Faltam
  157 dos 14.994 prefixos distintos de clientes e 7 dos 2.246 prefixos
  distintos de vendedores. Isso corresponde a aproximadamente 98,95% e
  99,69% de cobertura, respectivamente.
- **Interpretação:** o enriquecimento geográfico é opcional e não deve eliminar
  pedidos ou vendedores sem correspondência.
- **Possível implicação:** relatórios por UF devem explicitar a categoria
  “sem correspondência” quando aplicável e validar zeros à esquerda dos CEPs.
- **Fonte/consulta:** reconciliação de prefixos documentada no README e lógica
  de [`dim_geography.sql`](../models/olist/marts/dim_geography.sql).

### 5. A modelagem evita uma duplicação conhecida em joins de fatos

- **Pergunta de negócio:** qual o risco de combinar itens, pagamentos e
  avaliações diretamente por pedido?
- **Resultado quantitativo:** uma simulação de `LEFT JOIN` sem agregação prévia
  produziu 118.310 linhas a partir de 112.650 itens. A soma de pagamentos nessa
  simulação chegou a R$ 20.416.842,54, contra R$ 16.008.872,12 no fato de
  pagamentos; a soma de itens também aumentou de R$ 13.591.643,70 para
  R$ 14.273.699,65.
- **Interpretação:** a multiplicação é efeito de cardinalidade, não crescimento
  real de vendas. Os fatos materializados preservam suas somas porque não
  implementam esse join.
- **Possível implicação:** para visuais no grão de pedido, agregue cada fato
  separadamente por `order_id` antes de combinar resultados.
- **Fonte/consulta:** simulação de join e reconciliação documentadas na seção
  “Resultados dos testes e reconciliação” do README.

## Indicadores DAX verificados no modelo

As definições das medidas foram conferidas no TMDL e os resultados foram
consultados no modelo Import aberto. As elegibilidades são distintas:

| Tema | Regra |
| --- | --- |
| Pontualidade | Pedidos delivered com entrega real e previsão preenchidas; compara datas sem horário. |
| Tempo médio de entrega | Pedidos delivered com compra e entrega real preenchidas e duração não negativa; dias corridos com frações de dia. |
| Satisfação por avaliação | Média por registro; notas 4 e 5 são positivas. |
| Satisfação por pedido | Calcula primeiro a média de cada pedido e depois a média entre pedidos avaliados, com peso igual por pedido. |

## Análises de negócio validadas no Power BI

**Status: 7 de 7 análises executadas e conferidas no snapshot Import.**
Essa verificação não confirma uma atualização recente do Snowflake.

### 1. Evolução mensal dos pedidos e do valor dos itens

O maior volume observado foi em **2017-11**, com **7.544 pedidos** e **R$ 1.010.271,37** em preços de itens, considerando todos os status. Nesse mês, 7.289 pedidos tinham status delivered, associados a R$ 987.765,37 em itens.

Comparando janeiro–agosto, o valor dos itens passou de **R$ 3.113.000,32 em 2017** para **R$ 7.385.905,80 em 2018**, variação de **137,26%**. A comparação usa os mesmos meses.

| Mês da compra | Pedidos | Entregues | Valor dos itens — todos os status | Ticket dos itens |
| --- | --- | --- | --- | --- |
| 2016-09 | 4 | 1 | R$ 267,36 | R$ 89,12 |
| 2016-10 | 324 | 265 | R$ 49.507,66 | R$ 160,74 |
| 2016-12 | 1 | 1 | R$ 10,90 | R$ 10,90 |
| 2017-01 | 800 | 750 | R$ 120.312,87 | R$ 152,49 |
| 2017-02 | 1.780 | 1.653 | R$ 247.303,02 | R$ 142,70 |
| 2017-03 | 2.682 | 2.546 | R$ 374.344,30 | R$ 141,74 |
| 2017-04 | 2.404 | 2.303 | R$ 359.927,23 | R$ 150,53 |
| 2017-05 | 3.700 | 3.546 | R$ 506.071,14 | R$ 138,27 |
| 2017-06 | 3.245 | 3.135 | R$ 433.038,60 | R$ 134,61 |
| 2017-07 | 4.026 | 3.872 | R$ 498.031,48 | R$ 125,48 |
| 2017-08 | 4.331 | 4.193 | R$ 573.971,68 | R$ 133,70 |
| 2017-09 | 4.285 | 4.150 | R$ 624.401,69 | R$ 147,16 |
| 2017-10 | 4.631 | 4.478 | R$ 664.219,43 | R$ 145,41 |
| 2017-11 | 7.544 | 7.289 | R$ 1.010.271,37 | R$ 135,59 |
| 2017-12 | 5.673 | 5.513 | R$ 743.914,17 | R$ 132,27 |
| 2018-01 | 7.269 | 7.069 | R$ 950.030,36 | R$ 131,58 |
| 2018-02 | 6.728 | 6.555 | R$ 844.178,71 | R$ 126,11 |
| 2018-03 | 7.211 | 7.003 | R$ 983.213,44 | R$ 136,79 |
| 2018-04 | 6.939 | 6.798 | R$ 996.647,75 | R$ 143,73 |
| 2018-05 | 6.873 | 6.749 | R$ 996.517,68 | R$ 145,41 |
| 2018-06 | 6.167 | 6.099 | R$ 865.124,31 | R$ 140,44 |
| 2018-07 | 6.292 | 6.159 | R$ 895.507,22 | R$ 142,76 |
| 2018-08 | 6.512 | 6.351 | R$ 854.686,33 | R$ 132,47 |
| 2018-09 | 16 | — | R$ 145,00 | R$ 145,00 |
| 2018-10 | 4 | — | — | — |

`—` preserva o resultado vazio da medida. Meses sem pedidos, como novembro de 2016, não aparecem nessa consulta. Os registros residuais de setembro/outubro de 2018 não devem ser interpretados como queda operacional comparável aos meses anteriores. Ticket usa pedidos distintos com itens.

### 2. Participação das categorias

As cinco maiores categorias concentram **39,74%** do valor dos itens. `beleza_saude` lidera em valor; `cama_mesa_banho` tem mais itens entre essas categorias líderes.

| Categoria original | Valor dos itens | Participação | Itens |
| --- | --- | --- | --- |
| `beleza_saude` | R$ 1.258.681,34 | 9,26% | 9.670 |
| `relogios_presentes` | R$ 1.205.005,68 | 8,87% | 5.991 |
| `cama_mesa_banho` | R$ 1.036.988,68 | 7,63% | 11.115 |
| `esporte_lazer` | R$ 988.048,97 | 7,27% | 8.641 |
| `informatica_acessorios` | R$ 911.954,32 | 6,71% | 7.827 |
| `moveis_decoracao` | R$ 729.762,49 | 5,37% | 8.334 |
| `cool_stuff` | R$ 635.290,85 | 4,67% | 3.796 |
| `utilidades_domesticas` | R$ 632.248,66 | 4,65% | 6.964 |
| `automotivo` | R$ 592.720,11 | 4,36% | 4.235 |
| `ferramentas_jardim` | R$ 485.256,46 | 3,57% | 4.347 |

O grupo sem categoria tem **1.603 itens**, **R$ 179.535,28** e **1,32%** do valor. Separadamente, **623 produtos** e **1.627 itens** não têm categoria em inglês, incluindo casos sem categoria original. Ausência de categoria e ausência de tradução são indicadores diferentes.

### 3. Vendedores líderes

Critério: **valor dos itens, todos os status**. Os dez vendedores representam **13,15%** do valor dos itens. Os códigos abaixo são identificadores da origem.

| Vendedor | Valor dos itens | Itens | Pedidos com itens |
| --- | --- | --- | --- |
| `4869f7a5dfa277a7dca6462dcf3b52b2` | R$ 229.472,63 | 1.156 | 1.132 |
| `53243585a1d6dc2643021fd1853d8905` | R$ 222.776,05 | 410 | 358 |
| `4a3ca9315b744ce9f8e9374361493884` | R$ 200.472,92 | 1.987 | 1.806 |
| `fa1c13f2614d7b5c4749cbc52fecda94` | R$ 194.042,03 | 586 | 585 |
| `7c67e1448b00f6e969d365cea6b010ab` | R$ 187.923,89 | 1.364 | 982 |
| `7e93a43ef30c4f03f38b393420bc753a` | R$ 176.431,87 | 340 | 336 |
| `da8622b14eb17ae2831f4ac5b9dab84a` | R$ 160.236,57 | 1.551 | 1.314 |
| `7a67c85e85bb2ce8582c35f2203ad736` | R$ 141.745,53 | 1.171 | 1.160 |
| `1025f0e2d44d7041d6cf58b6550e0bfa` | R$ 138.968,55 | 1.428 | 915 |
| `955fee9216a65b617aa5c0531780ce60` | R$ 135.171,70 | 1.499 | 1.287 |

Esse ranking não é por quantidade, margem, receita líquida ou pagamentos. Um pedido com vários vendedores pode aparecer na contagem de mais de um vendedor.

### 4. Distribuição por UF do cliente

**SP** concentra **41,98% dos pedidos** e **38,28% do valor dos itens**. SP, RJ e MG somam **63,37%** do valor dos itens. O filtro da dimensão de clientes alcança pedidos e itens pelas relações 1:N, e as UFs reconciliam com os totais globais.

| UF | Pedidos | Valor dos itens | Participação no valor |
| --- | --- | --- | --- |
| SP | 41.746 | R$ 5.202.955,05 | 38,28% |
| RJ | 12.852 | R$ 1.824.092,67 | 13,42% |
| MG | 11.635 | R$ 1.585.308,03 | 11,66% |
| RS | 5.466 | R$ 750.304,02 | 5,52% |
| PR | 5.045 | R$ 683.083,76 | 5,03% |
| SC | 3.637 | R$ 520.553,34 | 3,83% |
| BA | 3.380 | R$ 511.349,99 | 3,76% |
| DF | 2.140 | R$ 302.603,94 | 2,23% |
| GO | 2.020 | R$ 294.591,95 | 2,17% |
| ES | 2.033 | R$ 275.037,31 | 2,02% |
| PE | 1.652 | R$ 262.788,03 | 1,93% |
| CE | 1.336 | R$ 227.254,71 | 1,67% |
| PA | 975 | R$ 178.947,81 | 1,32% |
| MT | 907 | R$ 156.453,53 | 1,15% |
| MA | 747 | R$ 119.648,22 | 0,88% |
| MS | 715 | R$ 116.812,64 | 0,86% |
| PB | 536 | R$ 115.268,08 | 0,85% |
| PI | 495 | R$ 86.914,08 | 0,64% |
| RN | 485 | R$ 83.034,98 | 0,61% |
| AL | 413 | R$ 80.314,81 | 0,59% |
| SE | 350 | R$ 58.920,85 | 0,43% |
| TO | 280 | R$ 49.621,74 | 0,37% |
| RO | 253 | R$ 46.140,64 | 0,34% |
| AM | 148 | R$ 22.356,84 | 0,16% |
| AC | 81 | R$ 15.982,95 | 0,12% |
| AP | 68 | R$ 13.474,30 | 0,10% |
| RR | 46 | R$ 7.829,43 | 0,06% |

Complemento de frete: participação = frete / (valor dos itens + frete), no mesmo recorte de todos os status. As maiores participações foram:

| UF | Pedidos | Participação do frete |
| --- | --- | --- |
| RR | 46 | 22,21% |
| MA | 747 | 20,85% |
| RO | 253 | 19,84% |
| AM | 148 | 19,68% |
| PI | 495 | 19,62% |

RR tem apenas 46 pedidos; a base pequena limita a interpretação da posição. O ranking descreve este dataset, não todo o comércio de cada estado.

### 5. Prazo médio e taxa de atraso

- Pedidos com status delivered: **96.478**.
- Base elegível para pontualidade: **96.470**.
- Entregues excluídos da pontualidade por ausência de data real ou prevista: **8**.
- No prazo: **89.936 (93,23%)**.
- Atrasados: **6.534 (6,77%)**.
- Tempo médio entre compra e entrega: **12,56 dias**.

O tempo médio usa a elegibilidade própria da medida, descrita acima. Exemplos por UF:

| UF | Dias médios | Pedidos elegíveis | Atrasados | Taxa de atraso |
| --- | --- | --- | --- | --- |
| SP | 8,76 | 40.494 | 1.820 | 4,49% |
| RJ | 15,31 | 12.350 | 1.495 | 12,11% |
| MG | 12,01 | 11.354 | 519 | 4,57% |
| BA | 19,34 | 3.256 | 396 | 12,16% |
| MA | 21,57 | 717 | 125 | 17,43% |

A comparação não controla diferenças de rota, vendedor, produtos ou distância.

### 6. Satisfação dos clientes

- Registros de avaliação: **99.224**.
- Pedidos distintos avaliados: **98.673**.
- Nota média por registro: **4,0864 / 5**.
- Avaliações com notas 4 ou 5: **76.470 (77,07%)**.
- Nota média com peso igual por pedido avaliado: **4,0868 / 5**.

A visão por pedido impede que pedidos com mais avaliações recebam peso maior. A satisfação geral inclui todos os status; a comparação seguinte considera somente entregues com datas disponíveis.

### 7. Associação entre atraso e nota

População: pedidos delivered com entrega real e previsão disponíveis. Primeiro calcula a média das avaliações de cada pedido; depois compara a média entre pedidos avaliados de cada grupo. Nenhum join com itens ou pagamentos foi usado.

| Entrega | Pedidos elegíveis | Pedidos avaliados | Registros de avaliação | Nota média por pedido |
| --- | --- | --- | --- | --- |
| No prazo | 89.936 | 89.443 | 89.944 | 4,2906 |
| Atrasado | 6.534 | 6.381 | 6.409 | 2,2718 |

A diferença observada é de **2,02 pontos**, com nota menor no grupo atrasado. Os desvios-padrão das notas médias por pedido são 1,1479 para entregas no prazo e 1,5711 para atrasadas.

Esse resultado é uma **associação descritiva**, não uma conclusão causal. Não
houve controle por estado, categoria, vendedor, período ou outros fatores.
Pedidos sem avaliação não receberam nota zero.

## Implicações e próximos passos

- Investigar atrasos por rota, vendedor e período, considerando volume e base elegível.
- Manter separados valor dos itens, frete e pagamentos; os resultados não redefinem receita líquida.
- Se o modelo for atualizado, repetir a consulta e as reconciliações antes de substituir as evidências.
- Para ir além da associação entre atraso e satisfação, controlar o mix e definir uma estratégia adequada de inferência causal.

## Cuidados para leitura no Power BI

- O calendário está relacionado à **data da compra**, não à entrega ou avaliação.
- 2016 e 2018 são incompletos; setembro/outubro de 2018 são residuais.
- Itens, pagamentos e avaliações têm grãos distintos.
- Produto/vendedor não filtram automaticamente o cabeçalho no sentido inverso das relações; usar `Pedidos com Itens` nesses recortes.
- “Valor dos Itens” não é receita líquida sem regra de negócio adicional.
- A comparação atraso-nota é observacional e não demonstra causalidade.
