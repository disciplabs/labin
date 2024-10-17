import pandas as pd
import sys
if hasattr(sys, 'setdefaultencoding'):
    sys.setdefaultencoding('utf-8')

dados = {
    'Nome': ['Ana', 'Bruno', 'Carlos'],
    'Idade': [23, 35, 29],
    'Cidade': ['Sao Paulo', 'Rio de Janeiro', 'Belo Horizonte']
}
df = pd.DataFrame(dados)
df.to_csv('teste_gen.csv',index=False)
#print(f"json_output: {json_output[0]}")

