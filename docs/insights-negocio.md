# Insights de negócio — Olist V2

## Escopo e método

Este documento separa evidências quantitativas já verificadas de análises que
dependem de uma consulta conectada ao Snowflake ou de uma atualização do modelo
Import do Power BI. O PBIP local foi carregado para inspeção estrutural, mas as
consultas DAX foram recusadas pelo modo offline; por isso, não há números
inventados para os recortes que exigem dados ativos.

As métricas monetárias abaixo são descritivas dos fatos, não uma definição de
receita líquida. `Valor dos Itens` soma preços no grão de item; pagamentos têm
grão próprio e não devem ser unidos diretamente aos itens antes da agregação.
As análises temporais devem usar a data da compra e tratar 2016 e 2018 como
períodos incompletos.

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
  descrição de [`models/marts/schema.yml`](../models/marts/schema.yml).

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
  de [`dim_geography.sql`](../models/marts/dim_geography.sql).

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

## Indicadores DAX disponíveis no modelo

As medidas DAX de logística e satisfação foram verificadas estruturalmente no
modelo semântico e estão disponíveis para exploração após a atualização do
modelo Import:

| Tema | Indicadores disponíveis | Regra de interpretação |
| --- | --- | --- |
| Logística | `Pedidos com Entrega e Previsão`, `Pedidos Entregues no Prazo`, `Pedidos Entregues Atrasados`, `Taxa de Entrega no Prazo`, `Tempo Médio de Entrega (Dias)` | Consideram pedidos `delivered` com data real e data prevista preenchidas; “no prazo” compara a data da entrega, ignorando o horário, com a previsão. |
| Satisfação | `Avaliações Registradas`, `Pedidos Avaliados`, `Nota Média das Avaliações`, `Avaliações Positivas`, `Taxa de Avaliações Positivas` | A média e a taxa positiva são calculadas por registro de avaliação; avaliações e pedidos avaliados têm métricas de contagem diferentes. |

Essas medidas confirmam a existência das definições e dos denominadores no
modelo, mas não constituem uma validação quantitativa neste ambiente offline.
Os valores devem ser obtidos após conectar o Power BI ao Snowflake e atualizar
o modelo.

## Análises de negócio pendentes

As perguntas abaixo são suportadas pelo modelo e pelas medidas DAX, mas não
foram concluídas neste ambiente porque o modelo Import local não está conectado
a uma fonte com dados. Não devem ser apresentadas como conclusões.

| Pergunta | Campo/medida disponível | Status e próxima verificação |
| --- | --- | --- |
| Como pedidos e valor dos itens evoluem por mês? | `Dim_Calendario[Ano-Mes]`, `Pedidos Registrados`, `Valor dos Itens` | **Pendente.** Consultar por mês de `Data da Compra`; comparar anos somente após marcar 2016 e 2018 como incompletos. |
| Quais categorias têm maior participação? | `Dim_Produtos[Categoria do Produto (Português)]`, `Valor dos Itens`, `Participação do Valor dos Itens (%)` | **Pendente.** Agregar itens por categoria e tratar nulos/sem tradução separadamente. |
| Quais vendedores lideram vendas? | `Dim_Vendedores[ID do Vendedor]`, `Valor dos Itens`, `Pedidos com Itens` | **Pendente.** Definir se o ranking é por valor de itens, quantidade de itens ou pedidos distintos. |
| Como pedidos e vendas se distribuem por UF? | `Dim_Clientes[UF]`, `Pedidos Registrados`, `Valor dos Itens` | **Pendente.** Confirmar a direção dos filtros e a população (todos os pedidos ou somente entregues). |
| Qual o prazo médio e a taxa de atraso? | Medidas DAX de logística listadas acima | **Pendente quantitativo.** Executar sobre pedidos `delivered` com datas real e prevista não nulas. |
| Como está a satisfação? | Medidas DAX de satisfação listadas acima | **Pendente quantitativo.** Calcular por registro de avaliação e também validar uma visão por pedido, sem duplicar avaliações. |
| Atrasos se relacionam com notas? | Datas de entrega/previsão e `Nota da Avaliação` | **Pendente.** Criar grupos no prazo/atrasado, calcular estatísticas descritivas e tamanho da amostra; correlação não demonstra causalidade. |

## Cuidados para leitura no Power BI

- O calendário está relacionado à **data da compra**, não à data de entrega ou
  de avaliação.
- 2016 e 2018 são períodos incompletos no histórico e não devem ser comparados
  diretamente com anos completos.
- As medidas de itens e pagamentos pertencem a fatos de grãos diferentes.
- “Valor dos Itens” não é receita líquida sem uma regra de negócio adicional.
- Qualquer relação entre atraso e nota deve ser descrita como associação
  observada, com suas limitações, nunca como causalidade.
