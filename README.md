
# E-commerce Olist - V2

Projeto prático de **Analytics Engineering**, com ingestão no Snowflake, transformações em SQL e testes de qualidade no dbt.

[![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logoColor=white)](https://docs.snowflake.com/en/sql-reference)
[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)

> **Base analítica construída e testada:** nove views de staging, uma view intermediate e oito tabelas marts (quatro dimensões e quatro fatos) em `OLIST`. Os 56 testes do projeto passaram; os indicadores finais e o dashboard no Power BI são as próximas etapas.

## Sobre o Projeto

O Olist V2 evolui o [projeto de análise de e-commerce da V1](https://github.com/isaiassousa032/Projeto_Olist/tree/main), ampliando o foco para a construção da base analítica que sustenta os indicadores de negócio.

A proposta é organizar o caminho entre os arquivos brutos e o consumo no Power BI: preservar a origem dos dados, separar as responsabilidades de cada camada, padronizar os campos e validar regras de qualidade por meio de código versionado.

O domínio continua sendo a operação de um marketplace: clientes, pedidos, itens, pagamentos, avaliações, produtos, vendedores e geolocalização. A implementação inclui ingestão, preparação dessas entidades e modelos dimensionais para análise.

### Evolução em relação à V1

| Aspecto | V1 | Direção da V2 |
| --- | --- | --- |
| Armazenamento | PostgreSQL hospedado no Neon | Snowflake |
| Preparação dos dados | Power Query | Modelos SQL no dbt, executados no Snowflake |
| Organização | Modelagem voltada ao relatório no Power BI | Camadas RAW, staging, intermediate e marts |
| Qualidade | Tratamentos e validações no fluxo analítico | Testes de dados declarados junto à documentação dos modelos |
| Visualização | Dashboard publicado no Power BI | Consumo dos marts no Power BI, ainda não implementado |

O [dashboard interativo da V1](https://app.powerbi.com/view?r=eyJrIjoiZWM5YzNlNDQtZjMyZi00NDNmLThlODYtOTlmMjQ0MmJlZmY0IiwidCI6IjQwNTBmNTliLTViYTItNGEwOS04NDU4LWI2MjUwOWM0Yzk3ZCJ9) permanece como referência das visões de negócio. A V2 ainda não possui dashboard próprio publicado.

## Fonte dos Dados

O projeto utiliza os nove arquivos CSV do [Brazilian E-Commerce Public Dataset by Olist, disponível no Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

| Tabela RAW | Conteúdo e granularidade considerada |
| --- | --- |
| `CUSTOMERS` | Registro por `customer_id`; `customer_unique_id` identifica o comprador entre compras. |
| `ORDERS` | Registro por pedido, com status e datas do ciclo de compra e entrega. |
| `ORDER_ITEMS` | Registro por item sequencial dentro do pedido. |
| `ORDER_PAYMENTS` | Registro por sequência de pagamento dentro do pedido. |
| `ORDER_REVIEWS` | Registros de avaliações; um pedido pode ter mais de uma avaliação. |
| `PRODUCTS` | Registro por produto, com categoria e atributos descritivos e físicos. |
| `SELLERS` | Registro por vendedor. |
| `GEOLOCATION` | Registros geográficos por prefixo de CEP, que pode se repetir. |
| `PRODUCT_CATEGORY_NAME_TRANSLATION` | Correspondência entre categorias em português e inglês. |

A fonte é um conjunto histórico estático. O fluxo atual utiliza carga de arquivos e execução dos modelos sob demanda, sem ingestão contínua ou orquestração com Airflow implementadas.

## Arquitetura e Engenharia de Dados

![Arquitetura de dados do projeto Olist V2](docs/arquitetura-de-dados-olist-v2.png)

```text
CSV do Kaggle
    → Stage interno no Snowflake
    → OLIST.RAW — tabelas com os dados de origem
    → OLIST.STAGING — nove views de preparação, gerenciadas pelo dbt
    → OLIST.INTERMEDIATE — projeção explícita de clientes
    → OLIST.MARTS — fatos e dimensões separados por grão
    → Power BI — indicadores e visualizações da V2 [planejado]
```

As configurações estão em [dbt_project.yml](dbt_project.yml). Staging e intermediate estão materializadas como **views**; marts, como **tabelas**. As contagens e os testes efetivamente verificados estão registrados na seção de resultados.

A macro [generate_schema_name.sql](macros/generate_schema_name.sql) utiliza diretamente o nome de schema configurado para cada camada, sem acrescentar o prefixo de `target.schema`. Para separar ambientes que usam esses mesmos nomes, é necessário considerar também o banco de destino.

### Etapas do desenvolvimento

1. **Infraestrutura e acesso:** scripts para criação do banco `OLIST`, schemas planejados, warehouse `OLIST_WH` e papel `OLIST_DBT_ROLE`.
2. **Ingestão:** stage interno, formato CSV com leitura de cabeçalhos, inspeção com `INFER_SCHEMA` e carga com `COPY INTO` e `MATCH_BY_COLUMN_NAME`.
3. **Modelagem física:** diagrama e SQL de referência para entidades, chaves, relacionamentos e granularidades.
4. **Staging:** nove modelos SQL para limpeza de textos, padronização de campos e renomeação de colunas.
5. **Qualidade e documentação:** descrições e testes de dados distribuídos nos arquivos `schema.yml` de staging, intermediate e marts.
6. **Marts:** dimensões de clientes, produtos, vendedores e geografia; fatos de pedidos, itens, pagamentos e avaliações.
7. **Próximas etapas:** acordar os indicadores e construir o consumo no Power BI.

## Transformações com dbt

Os modelos de staging seguem a sequência de CTEs `source → cleaned → renamed → final`, separando a leitura da origem, os tratamentos, os aliases e a seleção de saída.

Entre os tratamentos implementados estão:

- Remoção de espaços em identificadores e textos com `TRIM`.
- Padronização de caixa em status, categorias, cidades e UFs com `LOWER`, `UPPER` e `INITCAP`, conforme o modelo.
- Conversão de comentários vazios de avaliações em `NULL` com `NULLIF`.
- Renomeação de campos para nomes de consumo mais claros, como `order_status → status`, `order_purchase_timestamp → purchased_at`, `payment_value → payment_amount` e `review_score → rating`.
- Correção dos nomes de origem `product_name_lenght` e `product_description_lenght` para `name_length` e `description_length` na saída do staging.

| Modelo | Responsabilidade |
| --- | --- |
| `stg_olist_customers` | Preparar identificadores e localização dos clientes. |
| `stg_olist_orders` | Padronizar status e nomes das datas do pedido. |
| `stg_olist_order_items` | Preparar identificadores, preço do item e valor do frete. |
| `stg_olist_order_payments` | Padronizar modalidade, parcelas e valor do pagamento. |
| `stg_olist_order_reviews` | Preparar notas, comentários e datas das avaliações. |
| `stg_olist_products` | Padronizar categorias e nomes dos atributos dos produtos. |
| `stg_olist_sellers` | Preparar identificadores e localização dos vendedores. |
| `stg_olist_geolocation` | Padronizar nomes de campos geográficos e textos de localização. |
| `stg_olist_product_category_name_translation` | Padronizar categorias em português e inglês. |

As nove fontes estão declaradas em [_src_olist.yml](models/staging/olist/_src_olist.yml), com origem em `OLIST.RAW`.

## Marts Analíticos

| Modelo | Grão | Observação |
| --- | --- | --- |
| `dim_customers` | `customer_id` | `customer_unique_id` pode se repetir; a localização é a do cadastro do pedido. |
| `dim_products` | `product_id` | Tradução de categoria opcional, preservando produtos sem tradução. |
| `dim_sellers` | `seller_id` | Dados cadastrais do vendedor. |
| `dim_geography` | Prefixo de CEP | Par cidade/UF mais frequente; desempate por UF e cidade; coordenadas médias do par escolhido. |
| `fct_orders` | `order_id` | Status e datas do ciclo de vida, sem filtro de status. |
| `fct_order_items` | `(order_id, order_item_id)` | Preço e frete por item; inclui data e cliente do pedido. |
| `fct_order_payments` | `(order_id, payment_sequential)` | Valor pago por modalidade e sequência. |
| `fct_order_reviews` | Registro da origem | Mantém IDs de avaliação repetidos e múltiplas avaliações por pedido. |

Evite juntar itens, pagamentos e avaliações diretamente antes de somar valores: cada conjunto pode conter várias linhas por pedido. Para análises no grão de pedido, agregue cada fato separadamente por `order_id` antes dos joins. Os modelos não definem faturamento nem ticket médio: é preciso acordar quais status entram na população, se frete compõe receita e qual data atribui a venda ao período. Prefixos de CEP podem ter tipos/zeros à esquerda diferentes entre cadastros e geolocalização; valide as chaves antes de usar essa dimensão em joins.

## Qualidade dos Dados

O arquivo [models/schema.yml](models/schema.yml) contém os testes de staging. Os testes de chaves e relacionamentos dos marts estão em [models/marts/schema.yml](models/marts/schema.yml).

| Tipo | Regra verificada |
| --- | --- |
| `not_null` | Preenchimento de identificadores e outros campos obrigatórios. |
| `unique` | Identificadores de entidades e chaves compostas dos fatos de itens e pagamentos. |
| `relationships` | Referências de staging e marts para suas entidades pai. |
| `accepted_values` | Valores permitidos para status dos pedidos e notas das avaliações. |

O domínio de `status` contempla `delivered`, `invoiced`, `shipped`, `canceled`, `unavailable`, `processing`, `created` e `approved`. As notas em `rating` devem estar entre **1 e 5**.

Os testes expressam as regras implementadas; seus resultados dependem da execução contra os dados do ambiente. `accepted_values` verifica os valores não nulos, enquanto `not_null` verifica o preenchimento. Veja a [documentação dos testes dbt](https://docs.getdbt.com/reference/resource-properties/data-tests).

As validações de carga em [07_carga_tabelas_raw.sql](snowflake_scripts/07_carga_tabelas_raw.sql) também incluem contagens das nove tabelas e consultas de unicidade e nulidade para identificadores de clientes, pedidos, produtos e vendedores.

### Resultados dos testes e reconciliação

Validação em `OLIST`, em 22/10/2026, com a role `OLIST_DBT_ROLE`: `dbt build --select path:models/intermediate path:models/marts` materializou **uma view intermediate e oito tabelas marts**, com **25 testes selecionados aprovados**. Depois, `dbt test` executou os **56 testes do projeto: 56 pass, 0 fail**, incluindo os testes de staging. O artefato local `target/run_results.json` confirma os 56 resultados `pass`; a duração informada para o comando foi **13,2 s**, enquanto o campo `elapsed_time` desse artefato registra **42,46 s**, portanto o artefato não confirma a duração informada.

As consultas de reconciliação abaixo foram executadas somente em leitura, após o build. Elas complementam os testes dbt e não modificam os dados.

| Entidade | RAW | STAGING |
| --- | ---: | ---: |
| Clientes | 99.441 | 99.441 |
| Geolocalização | 1.000.163 | 1.000.163 |
| Itens | 112.650 | 112.650 |
| Pagamentos | 103.886 | 103.886 |
| Avaliações | 99.224 | 99.224 |
| Pedidos | 99.441 | 99.441 |
| Traduções de categoria | 71 | 71 |
| Produtos | 32.951 | 32.951 |
| Vendedores | 3.095 | 3.095 |

As chaves `customer_id`, `order_id`, `product_id` e `seller_id` têm, respectivamente, 99.441, 99.441, 32.951 e 3.095 valores distintos para o mesmo número de linhas; as 71 categorias traduzidas também são únicas. As combinações `(order_id, order_item_id)` e `(order_id, payment_sequential)` são únicas nas 112.650 linhas de itens e 103.886 de pagamentos. Nenhuma dessas chaves é nula. Em contrapartida, `customer_unique_id` tem 96.096 valores distintos em 99.441 clientes e `review_id` tem 98.410 em 99.224 avaliações; não são chaves únicas nesses grãos. Geolocalização contém 19.015 prefixos distintos e 1.000.163 registros, sem nulos no prefixo.

| Modelo materializado | Linhas | Chaves distintas |
| --- | ---: | ---: |
| `int_olist_customers` (view) | 99.441 | 99.441 `customer_id` |
| `dim_customers` | 99.441 | 99.441 `customer_id` |
| `dim_geography` | 19.015 | 19.015 `zip_code_prefix` |
| `dim_products` | 32.951 | 32.951 `product_id` |
| `dim_sellers` | 3.095 | 3.095 `seller_id` |
| `fct_orders` | 99.441 | 99.441 `order_id` |
| `fct_order_items` | 112.650 | 112.650 `order_item_key` |
| `fct_order_payments` | 103.886 | 103.886 `order_payment_key` |
| `fct_order_reviews` | 99.224 | 98.410 `review_id` (não único) |

As chaves únicas acima não têm nulos. As nove contagens materializadas coincidem com as expectativas da origem; avaliações preservam os `review_id` repetidos. Há **zero órfãos** tanto nas referências obrigatórias de staging quanto nas dos marts: pedidos→clientes, itens→pedidos, itens→produtos, itens→vendedores, pagamentos→pedidos e avaliações→pedidos. A relação geográfica é opcional: 157 dos 14.994 prefixos distintos de clientes e 7 dos 2.246 de vendedores não aparecem em `dim_geography`, embora todos esses prefixos tenham cinco caracteres. `dim_products` preserva 13 produtos com categoria sem tradução e 610 sem categoria.

| Medida física | Soma RAW | Soma STAGING | Soma MARTS | Diferença STAGING→MARTS |
| --- | ---: | ---: | ---: | ---: |
| Preço dos itens (`price` → `item_price`) | 13.591.643,70 | 13.591.643,70 | 13.591.643,70 | 0,00 |
| Frete dos itens (`freight_value` → `freight_price`) | 2.251.909,54 | 2.251.909,54 | 2.251.909,54 | 0,00 |
| Pagamentos (`payment_value` → `payment_amount`) | 16.008.872,12 | 16.008.872,12 | 16.008.872,12 | 0,00 |

Comparando **somas agregadas separadamente por `order_id`** nos marts, pagamentos superam preço dos itens mais frete em 165.318,88 no conjunto completo: há 775 pedidos somente com pagamento, 1 somente com itens e, entre os 98.665 com ambos, 98.089 têm totais iguais e 576 têm diferenças. A divergência foi mantida; não se deve forçar igualdade, distribuir pagamentos pelos itens nem interpretar qualquer dessas somas como faturamento sem regra de negócio aprovada.

Uma simulação com `LEFT JOIN` de itens→pagamentos→avaliações por `order_id`, **sem agregação prévia**, produziu 118.310 linhas para 112.650 itens. Nela, a soma de `item_price` subiu de 13.591.643,70 para 14.273.699,65, a de frete de 2.251.909,54 para 2.370.031,65 e a de pagamentos de 16.008.872,12 para 20.416.842,54. O join parte de itens e também deixa de fora pedidos somente com pagamento; portanto, esses totais não representam uma reconciliação. Nos joins efetivamente usados pelos fatos (itens→pedidos e pagamentos→pedidos), as contagens e somas originais permaneceram inalteradas. No Power BI, não some medidas após unir fatos diretamente por pedido: agregue cada fato no grão desejado antes de combiná-los.

Os fatos preservaram os grãos de itens e pagamentos, sem multiplicar linhas ou somas na construção. A simulação acima é um alerta para a modelagem do dashboard, não um resultado de join implementado nos marts.

### Cuidados de modelagem

- **Cliente e comprador:** `customer_id` e `customer_unique_id` têm papéis diferentes; não se exige unicidade de `customer_unique_id` no staging de clientes.
- **Itens e pagamentos:** as granularidades são, respectivamente, `(order_id, order_item_id)` e `(order_id, payment_sequential)`; os marts verificam a unicidade das chaves compostas.
- **Geolocalização:** `dim_geography` escolhe, por prefixo, o par cidade/UF mais frequente e usa a média das coordenadas desse par. Nem todo prefixo dos cadastros precisa existir na origem geográfica.
- **Avaliações:** não se presume unicidade de `review_id` ou uma única avaliação por pedido.
- **Agregações:** integrar itens, pagamentos e avaliações exige controlar a cardinalidade para evitar multiplicação de valores.

## Modelagem Física

O diagrama registra a estrutura relacional de referência do domínio e os relacionamentos entre as entidades.

![Diagrama da modelagem física do Olist V2](modelagem_fisica/Diagrama%20Modelagem%20F%C3%ADsica%20Olist%20v2.png)

O [SQL da modelagem física](modelagem_fisica/olist-v2-modelagem-fisica.sql) inclui chaves, restrições, índices e chaves técnicas para geolocalização e avaliações. Ele é um artefato de referência relacional e contém instruções, como `CREATE INDEX`, que não devem ser tratadas como o DDL de implantação das tabelas RAW no Snowflake. O DDL usado para essa camada está em [06_cria_tabelas_raw.sql](snowflake_scripts/06_cria_tabelas_raw.sql).

## Estrutura do Repositório

```text
Projeto_Olist_v2/
├── analyses/                         # Consulta exploratória de clientes
├── docs/                             # Imagem da arquitetura de dados
├── macros/
│   └── generate_schema_name.sql      # Nomes dos schemas por camada
├── modelagem_fisica/                 # Diagrama e SQL de referência
├── models/
│   ├── schema.yml                    # Documentação e testes de staging
│   ├── staging/olist/
│   │   ├── _src_olist.yml             # Nove fontes em OLIST.RAW
│   │   └── stg_olist_*.sql            # Nove modelos de staging
│   ├── intermediate/
│   │   ├── int_olist_customers.sql    # Projeção explícita por customer_id
│   │   └── schema.yml                # Documentação do intermediate
│   └── marts/
│       ├── dim_*.sql                 # Quatro dimensões
│       ├── fct_*.sql                 # Quatro fatos
│       └── schema.yml                # Documentação e testes dos marts
├── seeds/                            # Reservado; sem seeds implementados
├── snapshots/                        # Reservado; sem snapshots implementados
├── snowflake_scripts/                # Sete scripts de configuração e carga
├── tests/                            # Reservado para testes SQL específicos
├── dbt_project.yml                   # Configuração das camadas
└── README.md
```

O schema `marts` está configurado no projeto, com oito modelos SQL. Os testes genéricos estão declarados em YAML, mesmo que a pasta `tests/` contenha apenas `.gitkeep`.

## Como Executar

### 1. Obter a branch da V2

```bash
git clone --branch v2-analytics-engineering --single-branch https://github.com/isaiassousa032/Projeto_Olist.git Projeto_Olist_v2
cd Projeto_Olist_v2
```

### 2. Preparar o Snowflake e carregar os arquivos

É necessário ter acesso a uma conta Snowflake e permissões para provisionar os objetos e conceder os acessos previstos nos scripts. Os CSVs devem ser obtidos no Kaggle; eles não estão incluídos no repositório.

| Ordem | Script | Objetivo |
| --- | --- | --- |
| 1 | [01_config_olist.sql](snowflake_scripts/01_config_olist.sql) | Criar banco, os quatro schemas planejados, warehouse e papel do dbt, se ausentes. |
| 2 | [02_permissoes_olist.sql](snowflake_scripts/02_permissoes_olist.sql) | Conceder leitura da RAW/STAGING e criação de views em STAGING/INTERMEDIATE e tabelas em MARTS; ajustar o usuário do `GRANT ROLE` para o seu ambiente. |
| 3 | [03_cria_stage.sql](snowflake_scripts/03_cria_stage.sql) | Criar o stage interno. |
| 4 | [04_cria_file_format.sql](snowflake_scripts/04_cria_file_format.sql) | Configurar a leitura dos CSVs. |
| 5 | [05_inspeciona_schemas.sql](snowflake_scripts/05_inspeciona_schemas.sql) | Inspecionar as colunas dos arquivos enviados. |
| 6 | [06_cria_tabelas_raw.sql](snowflake_scripts/06_cria_tabelas_raw.sql) | Criar as nove tabelas RAW. |
| 7 | [07_carga_tabelas_raw.sql](snowflake_scripts/07_carga_tabelas_raw.sql) | Carregar os arquivos e consultar as validações. |

Antes da inspeção e da carga, envie os nove CSVs ao stage `@OLIST.RAW.OLIST_CSV_STAGE`, preservando os nomes dos arquivos usados nos scripts. Selecione o warehouse `OLIST_WH` na sessão para executar as consultas e cargas.

Em uma instalação já provisionada, não é necessário recriar banco ou schemas. Verifique as concessões da role antes de materializar os novos modelos; os scripts de setup descrevem as permissões necessárias, mas editá-los não altera as concessões existentes no Snowflake.

### 3. Configurar a conexão do dbt

O desenvolvimento utiliza o **dbt Cloud / Studio**, conectado ao repositório e ao Snowflake. Configure a branch da V2 e as credenciais do ambiente, utilizando o banco `OLIST`, warehouse `OLIST_WH` e papel `OLIST_DBT_ROLE`, com acesso aos schemas de destino.

Para execução com dbt Core, é necessário instalar o dbt e o adaptador Snowflake e configurar externamente o perfil `default`, referenciado em `dbt_project.yml`. O repositório não inclui credenciais nem uma versão de runtime fixada; o ambiente precisa ser compatível com a sintaxe `data_tests` e `arguments` utilizada no YAML.

### 4. Construir e testar os modelos

No terminal do ambiente dbt configurado, quando RAW e STAGING já estiverem carregados:

```bash
# Compilar sem criar ou substituir relações
dbt compile --select path:models/intermediate path:models/marts

# Após confirmar destino e permissões, construir os modelos selecionados
dbt build --select path:models/intermediate path:models/marts

# Validar as dependências já existentes sem reconstruir STAGING
dbt test --select path:models/staging
```

O build acima inclui os testes associados aos modelos selecionados. Não use o prefixo `+` no ambiente já carregado: ele selecionaria também as views de STAGING existentes. Os destinos em `OLIST.INTERMEDIATE` e `OLIST.MARTS` **já estão materializados**; uma nova execução do build pode substituir essas relações e requer conferência e autorização prévias. As tabelas RAW não são selecionadas. O comportamento do build está descrito na [documentação do dbt](https://docs.getdbt.com/reference/commands/build).

## Indicadores e Visualização

As frentes de análise previstas para o consumo da V2 seguem os temas da V1:

- **Visão geral:** faturamento, pedidos, ticket médio e evolução temporal.
- **Eficiência logística:** tempos de entrega e cumprimento dos prazos estimados.
- **Satisfação do cliente:** notas das avaliações e diferenças por categoria.

Os valores publicados na V1 não são resultados validados da V2. As definições de receita, população de pedidos, período de análise e regras de agregação serão consolidadas junto aos marts antes da publicação dos indicadores.

O layout, as medidas DAX e o dashboard da V2 serão documentados quando implementados.

## Próximas Etapas

- [x] Criar a projeção intermediate de clientes.
- [x] Ampliar os testes declarados com unicidade das chaves compostas dos marts e relacionamentos.
- [x] Definir grãos e declarar os modelos de fatos e dimensões.
- [x] Confirmar destino e permissões e construir intermediate e marts com 25 testes aprovados.
- [x] Medir cobertura e formato dos prefixos de CEP nas fontes geográficas.
- [x] Executar os 56 testes do projeto, incluindo STAGING: 56 aprovados, nenhuma falha.
- [x] Reconciliar as medidas físicas de RAW, STAGING e MARTS.
- [ ] Definir receita, população de pedidos e datas dos indicadores para o Power BI.
- [ ] Conectar os marts ao Power BI e desenvolver as visões da V2.
- [x] Documentar as contagens, testes e medidas observadas nos marts.
- [ ] Publicar o dashboard da V2.

## Autor

Desenvolvido por **Isaias Santos**.

- [LinkedIn](https://www.linkedin.com/in/isaiassousadossantos/)
- [Meu Site / Portfólio](https://isaiassantos.works/)
