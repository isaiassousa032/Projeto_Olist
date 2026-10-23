# Validação das análises de negócio

Consultas DAX executadas em 23/10/2026 no modelo Import `Olist_Analytics_v2`
aberto no Power BI Desktop. Nenhum refresh foi acionado. A data da última
atualização da origem não foi obtida; os resultados representam o snapshot
carregado, com compras entre 04/09/2016 e 17/10/2018.

## Arquivos

| Arquivo | Conteúdo |
| --- | --- |
| `00_controle.dax` / `00_controle.tsv` | Contagens e limites temporais do modelo. |
| `01_consultas_pendentes.dax` | Consulta somente leitura das sete análises. |
| `01_resultados.tsv` | Exportação integral da tabela de resultados: 796 linhas, além do cabeçalho. |
| `resultados_estruturados.json` | Os mesmos resultados organizados por análise, grupo e métrica; vazios preservados como `null`. |
| `proveniencia.json` | Origem, data da execução e hashes dos arquivos de evidência. |
| `conferir_resultados.py` | Reconciliações locais, sem dependências externas. |
| `validacao_insights.ipynb` | Conferência com código, saídas e limitações registradas. |

## Como reproduzir

1. Abra o projeto no Power BI Desktop e confira a origem e a atualização do modelo.
2. Na exibição de consulta DAX, execute `00_controle.dax` e depois
   `01_consultas_pendentes.dax`. As consultas não criam medidas nem alteram tabelas.
3. Exporte a tabela inteira, preservando os cabeçalhos e a precisão numérica.
4. Execute `python analyses/powerbi_validacao/conferir_resultados.py` a partir
   da raiz do projeto. Para outro snapshot, revise as expectativas de contagem
   antes de substituir os arquivos históricos.

As conferências reconciliam totais mensais, categorias e UFs, participação das
categorias, base de pontualidade, grupos de atraso, avaliações e tamanho do top 10.
A tolerância absoluta monetária é de R$ 0,01 para diferenças de ponto flutuante.

Os recortes comerciais usam todos os status. `delivered` e bases elegíveis são
explicitados nas análises logísticas. Não se somam pedidos distintos entre
categorias ou vendedores, nem se combinam fatos diretamente no grão de item.

As conclusões estão em [insights de negócio](../../docs/insights-negocio.md).
As reconciliações históricas preservadas na primeira parte desse documento não
foram integralmente reexecutadas nesta verificação das sete perguntas pendentes.
