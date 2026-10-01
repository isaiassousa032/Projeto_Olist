# Projeto_Olist_v2

## Visão Geral

Projeto de analytics engineering (nivel medio). Organize fontes, modelos SQL e metricas antes da visualizacao.

## Problema de Negócio

Descreva as perguntas, os indicadores e quem consome as tabelas finais.

## Tecnologias

- SQL como camada principal de transformacao
- Python / Jupyter para exploracao pontual
- Power BI para consumo
- YAML de configuracao nos niveis medio e grande

## Arquitetura

Fontes -> modelos de preparacao -> (intermediario, se houver) -> apresentacao -> Power BI e analises.

## Estrutura de Pastas

- `modelos/intermediario`: regras de negocio reutilizaveis
- `sementes`: cadastros pequenos versionados
- `sql/testes`: checagens de qualidade
- `docs/metricas`: definicao de indicadores

## Pipeline

1. Documente as origens em `sql/fontes`.
2. Construa a preparacao em `modelos/preparacao`.
3. Publique tabelas de consumo em `modelos/apresentacao`.
4. Valide metricas e atualize o Power BI.

## Decisões de Limpeza

Registre chaves, nulos, granularidade e filtros que entram nos modelos.

## Perguntas de Negócio

Liste perguntas e a tabela de apresentacao que responde cada uma.

## Power BI

Aponte o modelo semantico para `modelos/apresentacao` (ou para a camada publicada equivalente).

## Insights

Anote achados que dependem da modelagem, nao so do grafico.

## Como Executar

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Ajuste os SQLs em `modelos` e execute no seu motor (DuckDB, warehouse, etc.).

## Melhorias

Novas fontes, testes de qualidade e documentacao de metricas.
