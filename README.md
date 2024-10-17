# labin

## Pasta hop_etl

### Usando hop com virtual env para processar dados usando pandas 
script_run_venv_with_hop_sample.hpl<br>
sample_script.py<br>
Observe que neste caso configuramos um ambiente virtual para ...\apache-hop-client-2.8.0\myenv instalando o usando o requirements.txt 
![image](https://github.com/user-attachments/assets/8e651e10-31e6-42ce-8c19-c1464e7c66b1)

Observe o conteúdo do arquivo python (normalmente não trabalha bem com acentos)
![image](https://github.com/user-attachments/assets/a3dd99e4-d0c9-43b8-ad3a-31bf3ea70d42)


### criação de dados usando linguagem python
python_script_generete_data.hpl

![image](https://github.com/user-attachments/assets/69ca23b4-05eb-495b-858b-ea355c70b9bd)

### Gerando dados de nome, endereço, salario e id usando Fake Data do Apache Hop para uma tabela do PostgreSQL
hopFakeData_name_address_sal_id_to_table.hpl
![image](https://github.com/user-attachments/assets/43b3f85f-1c56-4178-9d7f-9db4d5036bda)


### Gera dados de salario e usa o calculator para obter o valor elevado ao quadrado.
fake_price.hpl
![image](https://github.com/user-attachments/assets/448d7aed-83e7-4a82-abd1-87eaaf1ee3c2)

### Gera dados de salario e usa o script python para converter para float e obter uma multiplicação do valor do salário por 20.
python_script_generete_data_mult_sal_to_table.hpl
![image](https://github.com/user-attachments/assets/7c45712c-e4ee-49f8-9e00-981e13e2cada)

