from pathlib import Path
import csv, json, math
base=Path(__file__).resolve().parent
with (base/'01_resultados.tsv').open(encoding='utf-8-sig',newline='') as f:
    raw=list(csv.DictReader(f,delimiter='\t'))
assert len(raw)==796
sections={}
for row in raw:
    a,g,m,v=[row[k] for k in ['[Analise]','[Grupo]','[Metrica]','[Valor]']]
    target=sections.setdefault(a,{}).setdefault(g,{})
    assert m not in target
    target[m]=float(v) if v else None
control=sections['00_Controle']['Total']
checks=[]
for sec,metrics in [('01_Mensal',['Pedidos','Entregues','ValorItens']),('02_Categorias',['ValorItens','Itens']),('04_UF',['Pedidos','Entregues','ValorItens','Frete'])]:
    for metric in metrics:
        total=sum((v[metric] or 0) for v in sections[sec].values())
        assert math.isclose(total,control[metric],rel_tol=0,abs_tol=.01),(sec,metric)
        checks.append((sec,metric,total))
log=sections['05_Logistica']['Total'];sat=sections['06_Satisfacao']['Total'];late=sections['07_AtrasoNotas']
assert math.isclose(sum((v['Participacao'] or 0) for v in sections['02_Categorias'].values()),1,abs_tol=1e-9)
assert log['NoPrazo']+log['Atrasados']==log['BasePontualidade']
assert math.isclose(log['TaxaAtraso'],log['Atrasados']/log['BasePontualidade'],abs_tol=1e-12)
assert sum(v['Pedidos'] for v in late.values())==log['BasePontualidade']
assert sat['Avaliacoes']==control['Avaliacoes']
assert sat['PedidosAvaliados']<=sat['Avaliacoes']
assert len(sections['03_VendedoresTop10'])==10
print('16 checagens aprovadas; 796 linhas; tolerância monetária de R$ 0,01 para ponto flutuante.')
for check in checks:print(check)
