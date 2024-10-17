-- Instruções para excluir as tabelas com CASCADE

DROP TABLE IF EXISTS RelatorioPesquisadorInstituicao CASCADE;
DROP TABLE IF EXISTS RelatorioFinanceiro CASCADE;
DROP TABLE IF EXISTS RelatorioProgresso CASCADE;
DROP TABLE IF EXISTS DespesaProjeto CASCADE;
DROP TABLE IF EXISTS Financiamento CASCADE;
DROP TABLE IF EXISTS Proposta CASCADE;
DROP TABLE IF EXISTS Edital CASCADE;
DROP TABLE IF EXISTS EquipeProjeto CASCADE;
DROP TABLE IF EXISTS Projeto CASCADE;
DROP TABLE IF EXISTS Instituicao CASCADE;
DROP TABLE IF EXISTS Pesquisador CASCADE;

-- Instruções para excluir as views

DROP VIEW IF EXISTS Relatorio_Status_Projetos CASCADE;
DROP VIEW IF EXISTS Relatorio_Financeiro CASCADE;
DROP VIEW IF EXISTS Relatorio_Pesquisadores_Instituicoes CASCADE;


-- TABELAS DE GESTÃO DE PESQUISADORES E INSTITUIÇÕES

-- Tabela de Pesquisadores
CREATE TABLE Pesquisador (
    id_pesquisador SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    historico_projetos TEXT,
    financiamento_anterior NUMERIC(15, 2) DEFAULT 0.00,
    publicacoes TEXT
);

-- Tabela de Instituições
CREATE TABLE Instituicao (
    id_instituicao SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco TEXT,
    historico_projetos TEXT
);

-- Tabela de Projetos (associando pesquisadores e instituições)
CREATE TABLE Projeto (
    id_projeto SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    resumo TEXT NOT NULL,
    orcamento_aprovado NUMERIC(15, 2) NOT NULL,
    cronograma TEXT NOT NULL,
    instituicao_id INT,
    FOREIGN KEY (instituicao_id) REFERENCES Instituicao(id_instituicao)
);

-- Tabela de Equipes dos Projetos (associando pesquisadores a projetos)
CREATE TABLE EquipeProjeto (
    id_projeto INT,
    id_pesquisador INT,
    funcao VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_projeto, id_pesquisador),
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto),
    FOREIGN KEY (id_pesquisador) REFERENCES Pesquisador(id_pesquisador)
);

-- TABELAS DE GESTÃO DE FINANCIAMENTO

-- Tabela de Editais
CREATE TABLE Edital (
    id_edital SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    criterios TEXT NOT NULL,
    prazo DATE NOT NULL,
    requisitos TEXT
);

-- Tabela de Propostas de Projetos
CREATE TABLE Proposta (
    id_proposta SERIAL PRIMARY KEY,
    id_edital INT NOT NULL,
    id_projeto INT NOT NULL,
    data_submissao DATE NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Submetida', 'Aprovada', 'Reprovada')),
    avaliacao TEXT,
    FOREIGN KEY (id_edital) REFERENCES Edital(id_edital),
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- Tabela de Financiamentos
CREATE TABLE Financiamento (
    id_financiamento SERIAL PRIMARY KEY,
    id_projeto INT NOT NULL,
    valor_aprovado NUMERIC(15, 2) NOT NULL,
    etapas INT NOT NULL,
    valor_liberado NUMERIC(15, 2) DEFAULT 0.00,
    data_liberacao DATE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Em Andamento', 'Concluído')),
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- Tabela de Despesas dos Projetos
CREATE TABLE DespesaProjeto (
    id_despesa SERIAL PRIMARY KEY,
    id_projeto INT NOT NULL,
    descricao TEXT NOT NULL,
    valor NUMERIC(15, 2) NOT NULL,
    data DATE NOT NULL,
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- TABELAS DE RELATÓRIOS E ACOMPANHAMENTO

-- Tabela de Relatórios de Progresso
CREATE TABLE RelatorioProgresso (
    id_relatorio SERIAL PRIMARY KEY,
    id_projeto INT NOT NULL,
    data_submissao DATE NOT NULL,
    status_projeto VARCHAR(255),
    descricao TEXT NOT NULL,
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- Tabela de Relatórios Financeiros
CREATE TABLE RelatorioFinanceiro (
    id_relatorio_financeiro SERIAL PRIMARY KEY,
    id_projeto INT NOT NULL,
    data_submissao DATE NOT NULL,
    valor_gasto NUMERIC(15, 2) NOT NULL,
    valor_aprovado NUMERIC(15, 2) NOT NULL,
    conformidade BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- Tabela de Relatórios de Pesquisadores e Instituições
CREATE TABLE RelatorioPesquisadorInstituicao (
    id_relatorio SERIAL PRIMARY KEY,
    id_pesquisador INT,
    id_instituicao INT,
    id_projeto INT,
    descricao TEXT NOT NULL,
    FOREIGN KEY (id_pesquisador) REFERENCES Pesquisador(id_pesquisador),
    FOREIGN KEY (id_instituicao) REFERENCES Instituicao(id_instituicao),
    FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- CONSULTAS SUGERIDAS (relatórios integrados)

-- Relatório de Status dos Projetos
CREATE VIEW Relatorio_Status_Projetos AS
SELECT 
    p.titulo, 
    p.resumo, 
    p.orcamento_aprovado, 
    r.status_projeto, 
    r.descricao AS descricao_progresso
FROM Projeto p
JOIN RelatorioProgresso r ON p.id_projeto = r.id_projeto;

-- Relatório Financeiro
CREATE VIEW Relatorio_Financeiro AS
SELECT 
    p.titulo, 
    r.valor_gasto, 
    r.valor_aprovado, 
    r.conformidade
FROM Projeto p
JOIN RelatorioFinanceiro r ON p.id_projeto = r.id_projeto;

-- Relatório de Pesquisadores e Instituições
CREATE VIEW Relatorio_Pesquisadores_Instituicoes AS
SELECT 
    pe.nome AS pesquisador_nome, 
    i.nome AS instituicao_nome, 
    p.titulo AS projeto_titulo, 
    r.descricao
FROM RelatorioPesquisadorInstituicao r
JOIN Pesquisador pe ON r.id_pesquisador = pe.id_pesquisador
JOIN Instituicao i ON r.id_instituicao = i.id_instituicao
JOIN Projeto p ON r.id_projeto = p.id_projeto;

-- INSERÇÃO DE DADOS

-- Inserindo Pesquisadores
INSERT INTO Pesquisador (nome, email, historico_projetos, financiamento_anterior, publicacoes) 
VALUES 
('Lucas Almeida', 'lucas.almeida@projetosaude.org', 'Plataforma de Inteligência Artificial para Saúde, Análise de Big Data para Saúde Pública', 10000.00, 'Análise de Dados em Saúde Pública, IA aplicada à Medicina'),
('Ana Torres', 'ana.torres@smartcitieslab.com', 'Sistema de Monitoramento de Dados Urbanos para Cidades Inteligentes', 20000.00, 'Internet das Coisas e Cidades Inteligentes, Big Data na Gestão Urbana'),
('Carlos Mendes', 'carlos.mendes@aiassist.com', 'Chatbots Inteligentes para Atendimento em Serviços Públicos', 15000.00, 'IA Conversacional e Aplicações em Serviços Públicos, Automação Governamental com IA'),
('Marina Lopes', 'marina.lopes@researchhealth.net', 'Análise de Sentimento em Redes Sociais para Políticas Públicas', 25000.00, 'Processamento de Linguagem Natural, Análise de Sentimento e Políticas Públicas'),
('Bruno Neves', 'bruno.neves@blockchaininnovation.org', 'Blockchain para Gestão Segura de Dados Médicos', 30000.00, 'Segurança de Dados em Saúde, Blockchain e Privacidade de Informações'),
('Camila Rocha', 'camila.rocha@meddiagnostics.com', 'Diagnóstico Automatizado com IA em Imagens Médicas', 35000.00, 'Diagnóstico por Imagem, IA aplicada à Radiologia'),
('Pedro Moreira', 'pedro.moreira@wearabletech.net', 'Monitoramento de Bem-Estar de Idosos com Dispositivos Wearables', 50000.00, 'Tecnologia Wearable para Saúde, Monitoramento Remoto de Pacientes'),
('Juliana Souza', 'juliana.souza@recomendamed.org', 'Plataforma de Recomendação de Tratamentos Médicos com IA', 40000.00, 'Sistemas de Recomendação em Saúde, IA aplicada a Tratamentos Personalizados'),
('Felipe Cardoso', 'felipe.cardoso@roborehab.com', 'Integração de IA e Robótica para Reabilitação Física', 45000.00, 'Robótica na Reabilitação, IA em Dispositivos Assistivos'),
('Laura Costa', 'laura.costa@utimonitoring.org', 'Sistema de Monitoramento de Pacientes com IA em UTIs', 30000.00, 'Monitoramento Inteligente em UTIs, IA aplicada a Cuidados Intensivos'),
('Rodrigo Gomes', 'rodrigo.gomes@chronicdata.org', 'Análise de Dados para Prevenção de Doenças Crônicas', 25000.00, 'Prevenção de Doenças Crônicas com IA, Análise Preditiva em Saúde'),
('Patricia Fernandes', 'patricia.fernandes@eduai.net', 'IA para Previsão de Resultados Educacionais em Escolas Públicas', 28000.00, 'IA na Educação, Análise Preditiva no Ensino Público'),
('Rafael Oliveira', 'rafael.oliveira@facescansecurity.com', 'Sistema de Reconhecimento Facial para Segurança em Hospitais', 32000.00, 'Reconhecimento Facial em Segurança, IA aplicada a Ambientes de Saúde'),
('Isabela Ribeiro', 'isabela.ribeiro@governtech.ai', 'Automação de Processos em Governos Locais com IA', 38000.00, 'IA na Gestão Pública, Automação de Processos Governamentais'),
('Leonardo Martins', 'leonardo.martins@triagemmed.org', 'Solução de IA para Triagem de Pacientes em Pronto Socorro', 29000.00, 'IA em Triagem Médica, Automação de Atendimento em Emergências'),
('Sofia Santos', 'sofia.santos@occupationalhealthdata.com', 'Data Analytics para Gerenciamento de Saúde Ocupacional', 41000.00, 'Análise de Dados em Saúde Ocupacional, Monitoramento de Saúde no Trabalho'),
('Eduardo Lima', 'eduardo.lima@healthstock.org', 'IA para Otimização de Estoques em Hospitais', 49000.00, 'Gestão de Estoques com IA, Otimização de Recursos Hospitalares'),
('Fernanda Almeida', 'fernanda.almeida@publichealthanalytics.com', 'Plataforma de Apoio à Decisão para Políticas de Saúde Pública', 52000.00, 'Análise de Dados para Políticas Públicas, Apoio à Decisão em Saúde'),
('Gabriel Barbosa', 'gabriel.barbosa@frauddetect.ai', 'Aplicação de Machine Learning para Identificação de Fraudes em Saúde', 45000.00, 'Detecção de Fraudes em Saúde com IA, Machine Learning em Processos Financeiros'),
('Viviane Pereira', 'viviane.pereira@utimonitoring.com', 'Sistema de Monitoramento de Pacientes com IA em UTIs', 34000.00, 'Monitoramento em Tempo Real com IA, Cuidado Intensivo Automatizado'),
('Daniel Souza', 'daniel.souza@respiratorydiagnostics.ai', 'IA para Detecção de Doenças Respiratórias em Exames de Imagem', 37000.00, 'Diagnóstico por Imagem em Doenças Respiratórias, IA aplicada à Pneumologia'),
('Melissa Ribeiro', 'melissa.ribeiro@healthdatagov.org', 'Plataforma de Gerenciamento de Dados Clínicos com Big Data', 39000.00, 'Gerenciamento de Dados Clínicos, Big Data na Saúde'),
('Renato Cunha', 'renato.cunha@medchatbots.org', 'Chatbots com IA para Atendimento em Centros de Saúde', 42000.00, 'IA Conversacional para Atendimento em Saúde, Chatbots e Automação Médica'),
('Carolina Nunes', 'carolina.nunes@epidemiccontrol.ai', 'IA para Prevenção de Epidemias com Análise de Dados de Mobilidade', 50000.00, 'IA em Epidemiologia, Prevenção de Epidemias com Big Data'),
('Bruno Martins', 'bruno.martins@telemedicine.org', 'Plataforma de Telemedicina com Análise de Dados Médicos', 12000.00, 'Telemedicina e Análise de Dados em Tempo Real, IA para Atendimento Remoto'),
('Tatiana Mendes', 'tatiana.mendes@predictmed.org', 'Solução de IA para Previsão de Demandas de Medicamentos', 13000.00, 'Previsão de Demandas em Saúde com IA, Gestão de Recursos em Farmácias Hospitalares'),
('Lucas Oliveira', 'lucas.oliveira@realtimebigdata.org', 'Solução de Big Data para Análise de Dados Clínicos em Tempo Real', 11000.00, 'Análise de Dados Clínicos com Big Data, Monitoramento de Pacientes em Tempo Real'),
('Roberta Fernandes', 'roberta.fernandes@medchatbots.ai', 'Chatbots com IA para Atendimento em Centros de Saúde', 15000.00, 'Chatbots Inteligentes para Atendimento Médico, Automação de Serviços de Saúde'),
('Paulo Silva', 'paulo.silva@advancedbigdata.org', 'Solução Avançada de Big Data para Análise Clínica', 16000.00, 'Big Data Avançado em Saúde, Análise Clínica em Tempo Real'),
('Maria Ferreira', 'maria.ferreira@emergencytriage.ai', 'IA para Triagem em Emergências', 17000.00, 'IA em Triagem de Emergências, Automação de Processos Médicos');

-- Inserindo Instituições
INSERT INTO Instituicao (nome, endereco, historico_projetos)
VALUES
('Universidade Federal do Espírito Santo (UFES)', 'Avenida Fernando Ferrari, 514, Goiabeiras, Vitória - ES', 'Projetos em biotecnologia, saúde e sustentabilidade'),
('Instituto Capixaba de Pesquisa, Assistência Técnica e Extensão Rural (INCAPER)', 'Avenida Jerônimo Monteiro, 1000, Centro, Vitória - ES', 'Projetos em agricultura e desenvolvimento rural'),
('Faculdade Multivix Vitória', 'Rua Dr. João Carlos de Souza, Santa Lúcia, Vitória - ES', 'Projetos na área de saúde, tecnologia e engenharia'),
('Centro Universitário Vila Velha (UVV)', 'Rua Comissário José Dantas de Melo, Boa Vista, Vila Velha - ES', 'Pesquisas em ciências da saúde e engenharia biomédica'),
('Universidade Federal de Minas Gerais (UFMG)', 'Avenida Presidente Antônio Carlos, 6627, Pampulha, Belo Horizonte - MG', 'Projetos em educação, tecnologia e engenharia'),
('Instituto Federal do Espírito Santo (IFES)', 'Rua Barão de Itapemirim, 125, Santa Lúcia, Vitória - ES', 'Projetos de ensino técnico e tecnológico em diversas áreas'),
('Universidade Estadual de Campinas (UNICAMP)', 'Rua Sérgio Buarque de Holanda, 777, Cidade Universitária, Campinas - SP', 'Pesquisas em inteligência artificial e ciências da computação'),
('Centro de Pesquisas René Rachou (FIOCRUZ Minas)', 'Avenida Augusto de Lima, 1715, Barro Preto, Belo Horizonte - MG', 'Projetos em saúde pública e biomedicina'),
('Fundação de Amparo à Pesquisa do Espírito Santo (FAPES)', 'Avenida Marechal Mascarenhas de Moraes, 2025, Bento Ferreira, Vitória - ES', 'Projetos de apoio à pesquisa científica em diversas áreas'),
('Instituto Nacional de Pesquisas Espaciais (INPE)', 'Avenida dos Astronautas, 1758, São José dos Campos - SP', 'Pesquisas em geoinformação, meteorologia e clima espacial'),
('Faculdade Pio XII', 'Rua Álvaro Sarlo, 123, Vitória - ES', 'Projetos nas áreas de direito e administração'),
('Centro Universitário do Espírito Santo (UNESC)', 'Rua Maria Rita de Jesus, 300, Colatina - ES', 'Pesquisas em ciências sociais aplicadas e engenharia de produção'),
('Universidade de São Paulo (USP)', 'Avenida Professor Luciano Gualberto, 380, Butantã, São Paulo - SP', 'Projetos de inovação em tecnologia e saúde pública'),
('Fundação João Pinheiro', 'Alameda das Acácias, 70, Bairro São Luiz, Belo Horizonte - MG', 'Pesquisas em políticas públicas e economia'),
('Instituto de Pesquisas Energéticas e Nucleares (IPEN)', 'Avenida Professor Lineu Prestes, 2242, São Paulo - SP', 'Projetos em energia nuclear e tecnologia de materiais'),
('Faculdade Católica Salesiana', 'Rua Santa Filomena, 450, Santa Lúcia, Vitória - ES', 'Projetos educacionais e psicologia aplicada'),
('Universidade Estadual Paulista (UNESP)', 'Rua Quirino de Andrade, 215, São Paulo - SP', 'Pesquisas em ciências agrárias e engenharia florestal'),
('Centro Universitário São Camilo', 'Rua São Camilo, 50, Cachoeiro de Itapemirim - ES', 'Projetos na área de saúde e educação'),
('Instituto Agronômico de Campinas (IAC)', 'Avenida Barão de Itapura, 1481, Campinas - SP', 'Pesquisas em agronomia e sustentabilidade agrícola'),
('Fundação Oswaldo Cruz (FIOCRUZ)', 'Avenida Brasil, 4365, Manguinhos, Rio de Janeiro - RJ', 'Projetos em saúde pública e desenvolvimento de vacinas'),
('Centro de Pesquisa e Desenvolvimento em Telecomunicações (CPqD)', 'Rodovia Campinas-Mogi Mirim, Km 118,5, Campinas - SP', 'Pesquisas em telecomunicações e tecnologia da informação'),
('Universidade Federal Fluminense (UFF)', 'Rua Miguel de Frias, 9, Icaraí, Niterói - RJ', 'Projetos em saúde e ciências sociais'),
('Instituto Tecnológico de Aeronáutica (ITA)', 'Praça Marechal Eduardo Gomes, 50, São José dos Campos - SP', 'Projetos em engenharia aeronáutica e tecnologia espacial'),
('Faculdade Pitágoras de Linhares', 'Rua Augusto Calmon, 2497, Linhares - ES', 'Projetos em ciências econômicas e gestão de negócios'),
('Centro Universitário Estácio de Sá de Vitória', 'Rua Amélia da Cunha Ornelas, 100, Vitória - ES', 'Pesquisas em direito e administração'),
('Universidade Federal do Rio de Janeiro (UFRJ)', 'Avenida Pedro Calmon, 550, Cidade Universitária, Rio de Janeiro - RJ', 'Projetos em energia e engenharia química'),
('Centro Universitário Serra dos Órgãos (UNIFESO)', 'Avenida Alberto Torres, 111, Teresópolis - RJ', 'Projetos em biotecnologia e saúde animal'),
('Instituto de Matemática Pura e Aplicada (IMPA)', 'Estrada Dona Castorina, 110, Rio de Janeiro - RJ', 'Pesquisas em matemática aplicada e estatística');

-- Inserindo Projetos
INSERT INTO Projeto (titulo, resumo, orcamento_aprovado, cronograma, instituicao_id)
VALUES
('Plataforma de Inteligência Artificial para Saúde Pública', 'Desenvolvimento de uma plataforma de IA para analisar dados de saúde e auxiliar em diagnósticos e políticas de saúde pública.', 50000.00, 'Desenvolvimento, Implementação', 1),
('Análise de Big Data para Previsão de Demandas em Hospitais', 'Utilização de big data e IA para prever demanda por recursos em hospitais, otimizando o uso de leitos e equipamentos médicos.', 100000.00, 'Coleta de Dados, Análise, Implementação', 2),
('Sistema de Monitoramento de Dados Urbanos para Cidades Inteligentes', 'Desenvolvimento de um sistema de monitoramento de dados de infraestrutura e trânsito em tempo real, utilizando big data e IoT.', 75000.00, 'Desenvolvimento, Testes, Implementação', 3),
('Chatbots Inteligentes para Atendimento em Serviços Públicos', 'Criação de chatbots com IA para atendimento automatizado em serviços públicos, visando melhorar a eficiência e reduzir custos.', 200000.00, 'Desenvolvimento, Treinamento, Implantação', 4),
('Análise de Sentimento em Redes Sociais para Políticas Públicas', 'Aplicação de técnicas de processamento de linguagem natural (NLP) para análise de sentimentos em redes sociais sobre políticas públicas.', 30000.00, 'Coleta de Dados, Análise, Relatório', 5),
('Plataforma de Dados para Prevenção de Desastres Naturais', 'Criação de uma plataforma que usa big data e algoritmos preditivos para monitorar e prever desastres naturais, como enchentes e deslizamentos.', 120000.00, 'Desenvolvimento, Coleta de Dados, Testes', 6),
('Diagnóstico Automatizado com IA em Imagens Médicas', 'Desenvolvimento de um sistema de IA para análise automatizada de imagens médicas, como raio-X e ressonâncias magnéticas, para apoiar diagnósticos.', 95000.00, 'Pesquisa, Desenvolvimento, Testes', 7),
('Blockchain para Gestão Segura de Dados Médicos', 'Implementação de uma solução baseada em blockchain para garantir a segurança e a privacidade dos dados médicos em sistemas de saúde.', 60000.00, 'Desenvolvimento, Testes, Implementação', 8),
('Plataforma de Recomendação de Tratamentos Médicos com IA', 'Sistema baseado em IA para recomendar tratamentos médicos personalizados com base em históricos de pacientes e dados clínicos.', 130000.00, 'Pesquisa, Desenvolvimento, Testes, Implementação', 9),
('Integração de IA e Robótica para Reabilitação Física', 'Desenvolvimento de robôs inteligentes que auxiliam na reabilitação de pacientes com deficiências motoras.', 145000.00, 'Pesquisa, Desenvolvimento, Testes', 10),
('Monitoramento de Bem-Estar de Idosos com Dispositivos Wearables', 'Desenvolvimento de uma plataforma que utiliza wearables para monitorar a saúde e o bem-estar de idosos em tempo real.', 95000.00, 'Desenvolvimento, Testes, Implementação', 11),
('Análise de Dados para Prevenção de Doenças Crônicas', 'Criação de uma plataforma para análise de dados de saúde que visa identificar e prevenir doenças crônicas como diabetes e hipertensão.', 105000.00, 'Desenvolvimento, Implementação, Monitoramento', 12),
('IA para Previsão de Resultados Educacionais em Escolas Públicas', 'Utilização de IA para prever o desempenho de estudantes com base em dados demográficos e históricos de aprendizado.', 85000.00, 'Coleta de Dados, Análise, Testes', 13),
('Sistema de Reconhecimento Facial para Segurança em Hospitais', 'Implementação de reconhecimento facial com IA para monitoramento e segurança de pacientes e funcionários em hospitais.', 150000.00, 'Desenvolvimento, Testes, Implementação', 14),
('Automação de Processos em Governos Locais com IA', 'Desenvolvimento de soluções baseadas em IA para automatizar processos burocráticos e aumentar a eficiência de serviços governamentais.', 92000.00, 'Pesquisa, Desenvolvimento, Implementação', 15),
('Solução de IA para Triagem de Pacientes em Pronto Socorro', 'Desenvolvimento de um sistema inteligente que usa IA para realizar a triagem inicial de pacientes em pronto socorros, agilizando o atendimento.', 75000.00, 'Pesquisa, Desenvolvimento, Testes', 16),
('Data Analytics para Gerenciamento de Saúde Ocupacional', 'Plataforma de análise de dados para monitoramento da saúde de trabalhadores em ambientes industriais e prevenção de acidentes.', 118000.00, 'Desenvolvimento, Implementação', 17),
('IA para Otimização de Estoques em Hospitais', 'Desenvolvimento de um sistema de IA para otimizar o controle de estoques de medicamentos e equipamentos hospitalares.', 135000.00, 'Pesquisa, Desenvolvimento, Implementação', 18),
('Plataforma de Apoio à Decisão para Políticas de Saúde Pública', 'Criação de uma plataforma de apoio à decisão baseada em big data e IA para auxiliar gestores de saúde pública.', 160000.00, 'Pesquisa, Desenvolvimento, Implementação', 19),
('Aplicação de Machine Learning para Identificação de Fraudes em Saúde', 'Desenvolvimento de algoritmos de machine learning para identificar fraudes em processos de reembolso de saúde.', 85000.00, 'Pesquisa, Desenvolvimento, Testes', 20),
('Sistema de Monitoramento de Pacientes com IA em UTIs', 'Desenvolvimento de uma solução de IA para monitoramento em tempo real de pacientes em unidades de terapia intensiva (UTI).', 175000.00, 'Desenvolvimento, Testes, Implementação', 21),
('IA para Detecção de Doenças Respiratórias em Exames de Imagem', 'Desenvolvimento de IA para identificar doenças respiratórias em imagens de tomografia e raio-X.', 60000.00, 'Pesquisa, Desenvolvimento, Implementação', 22),
('Plataforma de Gerenciamento de Dados Clínicos com Big Data', 'Criação de uma plataforma de big data para armazenamento e análise de grandes volumes de dados clínicos.', 110000.00, 'Desenvolvimento, Implementação, Monitoramento', 23),
('Chatbots com IA para Atendimento em Centros de Saúde', 'Criação de chatbots inteligentes para atendimento ao público em centros de saúde, melhorando o acesso a informações e triagem inicial.', 120000.00, 'Desenvolvimento, Treinamento, Implementação', 24),
('IA para Prevenção de Epidemias com Análise de Dados de Mobilidade', 'Sistema baseado em IA que utiliza dados de mobilidade para prever e mitigar a disseminação de epidemias.', 80000.00, 'Pesquisa, Desenvolvimento, Testes', 25),
('Plataforma de Telemedicina com Análise de Dados Médicos', 'Criação de uma plataforma de telemedicina integrada a sistemas de IA para análise de dados médicos em tempo real.', 90000.00, 'Desenvolvimento, Testes, Implementação', 26),
('Solução de IA para Previsão de Demandas de Medicamentos', 'Desenvolvimento de uma solução baseada em IA para prever a demanda por medicamentos em hospitais e clínicas.', 160000.00, 'Pesquisa, Desenvolvimento, Testes', 27),
('Solução de Big Data para Análise de Dados Clínicos em Tempo Real', 'Desenvolvimento de uma solução de big data para análise e monitoramento de dados clínicos em tempo real, auxiliando no tratamento de pacientes.', 110000.00, 'Desenvolvimento, Implementação, Monitoramento', 28),
('Solução de Big Data para Análise de Dados Clínicos em Tempo Real - Versão Avançada', 'Versão aprimorada da solução de Big Data para análise de dados clínicos em tempo real.', 120000.00, 'Desenvolvimento, Implementação, Validação', 1),
('Sistema de IA para Triagem de Pacientes em Centros de Emergência', 'Desenvolvimento de sistema de IA para melhorar a triagem em emergências.', 90000.00, 'Pesquisa, Desenvolvimento, Testes, Implementação', 2);

-- Inserindo Editais (apenas alguns para ilustrar)

INSERT INTO Edital (titulo, descricao, criterios, prazo, requisitos)
VALUES
('Edital para Inovações em IA para Saúde', 'Seleção de projetos que visam desenvolver inovações em Inteligência Artificial aplicada à saúde, com foco em diagnóstico e tratamento automatizado.', 'Impacto no setor de saúde, Uso de IA, Viabilidade técnica', '2024-09-30', 'Instituições de ensino superior, Empresas de tecnologia'),
('Edital de Análise de Big Data para Saúde Pública', 'Projetos focados na análise de big data para otimização de políticas públicas e alocação de recursos na área da saúde.', 'Relevância social, Capacidade de análise de grandes volumes de dados, Inovação', '2025-01-31', 'Pesquisadores da área de saúde pública, Instituições de pesquisa'),
('Edital para Soluções em Cidades Inteligentes', 'Projetos voltados para a criação de plataformas inteligentes de monitoramento de dados urbanos, usando IoT e big data.', 'Inovação tecnológica, Impacto na mobilidade urbana, Sustentabilidade', '2025-06-30', 'Empresas de tecnologia, Instituições públicas e privadas'),
('Edital de Automação de Processos Públicos com IA', 'Fomento a soluções baseadas em IA para a automação de processos governamentais, visando redução de custos e aumento de eficiência.', 'Uso de IA, Automação de processos, Escalabilidade', '2025-02-28', 'Instituições públicas, Startups de tecnologia'),
('Edital de Análise de Sentimento para Políticas Públicas', 'Fomento a projetos de monitoramento de opinião pública por meio de análise de sentimento em redes sociais, aplicando técnicas de NLP.', 'Capacidade de análise em tempo real, Impacto social, Precisão dos modelos de NLP', '2025-05-30', 'Instituições de pesquisa, Organizações governamentais'),
('Edital de Blockchain para Gestão de Dados Médicos', 'Iniciativas de segurança e privacidade na gestão de dados médicos utilizando tecnologia blockchain para garantir a integridade dos registros.', 'Uso de blockchain, Segurança dos dados, Inovação tecnológica', '2025-07-31', 'Empresas de TI, Instituições de saúde'),
('Edital de IA para Diagnóstico de Imagens Médicas', 'Seleção de projetos para desenvolver algoritmos de IA voltados à análise de imagens médicas e apoio ao diagnóstico precoce.', 'Precisão dos algoritmos, Impacto na saúde, Viabilidade técnica', '2025-09-30', 'Instituições de saúde, Laboratórios de tecnologia'),
('Edital de Wearables para Monitoramento de Saúde de Idosos', 'Projetos que visam o desenvolvimento de dispositivos wearables para monitorar a saúde de idosos e prevenir emergências médicas.', 'Inovação em dispositivos, Impacto na saúde, Sustentabilidade', '2025-10-31', 'Empresas de tecnologia vestível, Instituições de saúde'),
('Edital de Análise Preditiva para Doenças Crônicas', 'Incentivo a soluções que utilizam big data e IA para prever e prevenir doenças crônicas, como diabetes e hipertensão.', 'Capacidade preditiva, Impacto na saúde, Eficiência dos algoritmos', '2025-12-31', 'Instituições de saúde pública, Empresas de tecnologia'),
('Edital de Robótica para Reabilitação Física', 'Projetos focados no desenvolvimento de robôs inteligentes para auxiliar em processos de reabilitação física de pacientes com mobilidade reduzida.', 'Inovação robótica, Impacto na reabilitação, Viabilidade técnica', '2026-02-28', 'Empresas de robótica, Instituições de saúde'),
('Edital para Soluções de IA em UTIs', 'Fomento ao desenvolvimento de sistemas de IA para monitoramento contínuo de pacientes em unidades de terapia intensiva (UTI).', 'Capacidade de monitoramento, Impacto no tratamento de pacientes, Sustentabilidade da solução', '2026-03-31', 'Hospitais, Instituições de pesquisa médica'),
('Edital de Soluções em Telemedicina com Big Data', 'Iniciativas que desenvolvam plataformas de telemedicina, integrando análise de big data para suporte a diagnósticos e acompanhamento de pacientes.', 'Capacidade de análise em tempo real, Impacto na saúde, Eficiência do sistema', '2026-04-30', 'Empresas de tecnologia, Instituições de saúde'),
('Edital de Machine Learning para Detecção de Fraudes em Saúde', 'Fomento a projetos que utilizam machine learning para identificar fraudes em processos de reembolso de saúde e serviços médicos.', 'Precisão do modelo de ML, Impacto na gestão de saúde, Viabilidade técnica', '2026-06-30', 'Empresas de TI, Instituições de saúde'),
('Edital de IA para Prevenção de Epidemias', 'Fomento a soluções baseadas em IA que utilizam dados de mobilidade e saúde para prever e prevenir a disseminação de epidemias.', 'Capacidade de previsão, Impacto na saúde pública, Inovação tecnológica', '2026-07-31', 'Pesquisadores, Instituições públicas de saúde'),
('Edital de Segurança de Dados Clínicos com Blockchain', 'Fomento ao desenvolvimento de soluções baseadas em blockchain para garantir a segurança e privacidade dos dados clínicos.', 'Uso de blockchain, Segurança dos dados, Sustentabilidade', '2026-08-31', 'Empresas de TI, Instituições de saúde'),
('Edital de IA para Gestão de Estoques Hospitalares', 'Projetos voltados ao uso de IA para otimização e previsão de demandas em estoques hospitalares, com foco em medicamentos e suprimentos.', 'Capacidade preditiva, Impacto na gestão hospitalar, Sustentabilidade da solução', '2026-09-30', 'Hospitais, Empresas de tecnologia'),
('Edital de IA para Triagem de Pacientes em Pronto-Socorro', 'Desenvolvimento de IA para realizar triagem inicial de pacientes em pronto-socorro, agilizando o atendimento e priorização de casos.', 'Precisão da triagem, Impacto na saúde, Eficiência do sistema', '2026-10-31', 'Instituições de saúde, Startups de IA'),
('Edital de Análise de Dados para Prevenção de Desastres Naturais', 'Fomento a soluções que utilizam big data e algoritmos preditivos para monitorar e prever desastres naturais.', 'Capacidade preditiva, Impacto social, Sustentabilidade da solução', '2026-11-30', 'Instituições públicas, Empresas de tecnologia'),
('Edital de Chatbots com IA para Atendimento em Centros de Saúde', 'Fomento a projetos de chatbots inteligentes para atendimento automatizado em centros de saúde, melhorando o acesso a informações e triagem inicial.', 'Capacidade de interação, Impacto na saúde, Escalabilidade', '2026-12-31', 'Empresas de tecnologia, Instituições de saúde'),
('Edital de IA para Gerenciamento de Dados em Tempo Real', 'Projetos voltados ao desenvolvimento de plataformas de big data para gerenciamento de dados clínicos em tempo real.', 'Capacidade de gerenciamento, Impacto na saúde, Eficiência do sistema', '2027-01-31', 'Instituições de saúde, Empresas de TI'),
('Edital de IA para Prevenção de Doenças Respiratórias', 'Iniciativas que utilizam IA para identificar doenças respiratórias, como COVID-19 e pneumonia, em exames de imagem.', 'Precisão da IA, Impacto na saúde pública, Sustentabilidade', '2027-02-28', 'Hospitais, Instituições de saúde pública'),
('Edital de IA para Gestão de Telemedicina', 'Fomento a soluções de IA para gestão e análise de dados em plataformas de telemedicina, melhorando o atendimento remoto de pacientes.', 'Capacidade de análise, Impacto no atendimento médico, Viabilidade técnica', '2027-03-31', 'Empresas de TI, Instituições de saúde'),
('Edital de Machine Learning para Prevenção de Doenças Crônicas', 'Fomento ao desenvolvimento de modelos de machine learning para prevenção de doenças crônicas em populações de risco.', 'Precisão do modelo, Impacto na saúde pública, Viabilidade técnica', '2027-04-30', 'Instituições de pesquisa médica, Empresas de TI'),
('Edital de IA para Previsão de Demandas em Hospitais', 'Desenvolvimento de soluções de IA para prever a demanda de leitos, medicamentos e recursos hospitalares.', 'Capacidade preditiva, Impacto na saúde, Sustentabilidade da solução', '2027-05-31', 'Hospitais, Empresas de tecnologia'),
('Edital de IA para Triagem de Pacientes em Centros de Emergência', 'Desenvolvimento de sistemas inteligentes de triagem para melhorar o atendimento em centros de emergência, utilizando IA e machine learning.', 'Precisão da triagem, Impacto na saúde, Escalabilidade', '2027-06-30', 'Instituições de saúde, Startups de tecnologia'),
('Edital de Segurança de Dados em Plataformas de Saúde', 'Fomento a soluções que garantem a segurança e privacidade dos dados em plataformas digitais de saúde.', 'Uso de criptografia, Segurança dos dados, Escalabilidade', '2027-07-31', 'Empresas de TI, Instituições de saúde'),
('Edital de IA para Telemedicina e Análise de Dados Clínicos', 'Projetos focados no desenvolvimento de IA para análise de dados clínicos em plataformas de telemedicina.', 'Capacidade de análise, Impacto no atendimento médico, Viabilidade técnica', '2027-08-31', 'Empresas de TI, Instituições de saúde'),
('Edital V2 para Inovações em IA para Saúde', 'Seleção de projetos que visam desenvolver inovações em Inteligência Artificial aplicada à saúde, com foco em diagnóstico e tratamento automatizado.', 'Impacto no setor de saúde, Uso de IA, Viabilidade técnica', '2024-12-31', 'Instituições de ensino superior, Empresas de tecnologia');

-- Inserindo Financiamentos
INSERT INTO Financiamento (id_projeto, valor_aprovado, etapas, valor_liberado, data_liberacao, status)
VALUES
(1, 50000.00, 2, 25000.00, '2024-06-01', 'Em Andamento'),
(2, 100000.00, 3, 50000.00, '2024-07-01', 'Em Andamento'),
(3, 75000.00, 4, 75000.00, '2024-08-01', 'Concluído'),
(4, 200000.00, 2, 100000.00, '2024-09-01', 'Em Andamento'),
(5, 30000.00, 1, 30000.00, '2024-09-15', 'Concluído'),
(6, 120000.00, 3, 40000.00, '2024-10-01', 'Em Andamento'),
(7, 95000.00, 2, 60000.00, '2024-11-01', 'Concluído'),
(8, 60000.00, 4, 30000.00, '2024-12-01', 'Em Andamento'),
(9, 130000.00, 2, 90000.00, '2024-12-15', 'Em Andamento'),
(10, 145000.00, 3, 70000.00, '2025-01-01', 'Em Andamento'),
(11, 95000.00, 2, 50000.00, '2025-01-15', 'Concluído'),
(12, 105000.00, 4, 65000.00, '2025-02-01', 'Em Andamento'),
(13, 85000.00, 2, 50000.00, '2025-02-15', 'Concluído'),
(14, 150000.00, 3, 100000.00, '2025-03-01', 'Em Andamento'),
(15, 92000.00, 2, 30000.00, '2025-03-15', 'Concluído'),
(16, 75000.00, 4, 35000.00, '2025-04-01', 'Em Andamento'),
(17, 118000.00, 2, 40000.00, '2025-04-15', 'Concluído'),
(18, 135000.00, 3, 80000.00, '2025-05-01', 'Em Andamento'),
(19, 160000.00, 2, 60000.00, '2025-05-15', 'Concluído'),
(20, 85000.00, 3, 50000.00, '2025-06-01', 'Em Andamento'),
(21, 175000.00, 2, 70000.00, '2025-06-15', 'Concluído'),
(22, 60000.00, 2, 30000.00, '2025-07-01', 'Em Andamento'),
(23, 110000.00, 3, 50000.00, '2025-07-15', 'Concluído'),
(24, 120000.00, 2, 70000.00, '2025-08-01', 'Em Andamento'),
(25, 80000.00, 3, 40000.00, '2025-08-15', 'Concluído'),
(26, 90000.00, 3, 50000.00, '2025-09-01', 'Em Andamento'),
(27, 160000.00, 2, 100000.00, '2025-09-15', 'Concluído'),
(28, 110000.00, 3, 60000.00, '2025-10-01', 'Em Andamento'),
(29, 120000.00, 2, 60000.00, '2025-10-15', 'Em Andamento'),
(30, 90000.00, 2, 45000.00, '2025-11-01', 'Em Andamento');

-- Inserindo Relatórios de Progresso
INSERT INTO RelatorioProgresso (id_projeto, data_submissao, status_projeto, descricao)
VALUES
(1, '2024-09-01', 'Em Andamento', 'A plataforma de IA para saúde está em fase de desenvolvimento de algoritmos preditivos.'),
(2, '2024-09-02', 'Concluído', 'O sistema de análise de big data para hospitais foi implementado com sucesso e está em operação.'),
(3, '2024-09-03', 'Em Andamento', 'O projeto de cidades inteligentes está na fase de coleta de dados urbanos para monitoramento em tempo real.'),
(4, '2024-09-04', 'Concluído', 'Os chatbots inteligentes para atendimento em serviços públicos já estão em operação em diversas prefeituras.'),
(5, '2024-09-05', 'Em Andamento', 'A análise de sentimento em redes sociais para políticas públicas está sendo testada com dados reais.'),
(6, '2024-09-06', 'Em Andamento', 'O sistema blockchain para gestão de dados médicos entrou em fase de testes de segurança.'),
(7, '2024-09-07', 'Concluído', 'O sistema de IA para diagnóstico de imagens médicas foi implementado e está em fase de avaliação clínica.'),
(8, '2024-09-08', 'Em Andamento', 'O desenvolvimento de wearables para monitoramento da saúde de idosos está em fase de prototipagem.'),
(9, '2024-09-09', 'Concluído', 'A plataforma de análise preditiva para doenças crônicas está em operação em hospitais públicos.'),
(10, '2024-09-10', 'Em Andamento', 'A integração de IA e robótica para reabilitação física está sendo testada com pacientes em reabilitação.'),
(11, '2024-09-11', 'Concluído', 'O sistema de monitoramento de UTIs com IA foi concluído e está sendo utilizado em hospitais parceiros.'),
(12, '2024-09-12', 'Em Andamento', 'A solução de telemedicina com big data está sendo aprimorada com novos algoritmos de análise de dados clínicos.'),
(13, '2024-09-13', 'Concluído', 'O sistema de machine learning para detecção de fraudes em saúde já está em operação em grandes hospitais.'),
(14, '2024-09-14', 'Em Andamento', 'O sistema de IA para prevenção de epidemias está sendo calibrado com dados de mobilidade urbana.'),
(15, '2024-09-15', 'Concluído', 'A plataforma de blockchain para gestão segura de dados clínicos foi finalizada e implantada em hospitais parceiros.'),
(16, '2024-09-16', 'Em Andamento', 'A IA para gestão de estoques hospitalares está em fase de testes para otimizar os recursos hospitalares.'),
(17, '2024-09-17', 'Concluído', 'O sistema de IA para triagem de pacientes em pronto-socorros foi implantado em diversas unidades de saúde.'),
(18, '2024-09-18', 'Em Andamento', 'A plataforma de análise de dados para prevenção de desastres naturais está sendo validada com simulações reais.'),
(19, '2024-09-19', 'Concluído', 'Os chatbots com IA para atendimento em centros de saúde foram implementados e já estão em uso.'),
(20, '2024-09-20', 'Em Andamento', 'A solução de IA para gerenciamento de dados clínicos em tempo real está em fase de integração com sistemas de saúde.'),
(21, '2024-09-21', 'Concluído', 'O sistema de IA para detecção de doenças respiratórias em exames de imagem foi concluído e validado por médicos.'),
(22, '2024-09-22', 'Em Andamento', 'A plataforma de IA para telemedicina está sendo aprimorada com novos recursos para análise de dados clínicos.'),
(23, '2024-09-23', 'Concluído', 'A solução de machine learning para prevenção de doenças crônicas já está em operação em hospitais.'),
(24, '2024-09-24', 'Em Andamento', 'O sistema de IA para previsão de demandas em hospitais está em fase de ajustes para otimizar a alocação de recursos.'),
(25, '2024-09-25', 'Concluído', 'O sistema de IA para triagem de pacientes em centros de emergência foi finalizado e implantado.'),
(26, '2024-09-26', 'Em Andamento', 'A plataforma de segurança de dados em saúde está sendo testada para garantir privacidade em sistemas digitais de saúde.'),
(27, '2024-09-27', 'Concluído', 'O projeto de IA para análise de dados clínicos em telemedicina foi finalizado e está em uso.'),
(28, '2024-09-28', 'Em Andamento', 'A solução de IA para análise de dados clínicos em tempo real está em fase de implementação em hospitais parceiros.'),
(29, '2024-09-29', 'Em Andamento', 'A solução de big data para análise de dados clínicos em tempo real está sendo validada com dados hospitalares.'),
(30, '2024-09-30', 'Concluído', 'O sistema de IA para triagem de pacientes em centros de emergência foi finalizado e validado.');

-- Inserindo Equipes dos Projetos
INSERT INTO EquipeProjeto (id_projeto, id_pesquisador, funcao)
VALUES
(1, 1, 'Coordenador'),
(1, 2, 'Pesquisador Sênior'),
(1, 3, 'Pesquisador Júnior'),
(1, 4, 'Assistente'),
(2, 5, 'Pesquisador Sênior'),
(2, 6, 'Pesquisador Júnior'),
(2, 7, 'Coordenador'),
(3, 8, 'Pesquisador Sênior'),
(3, 9, 'Assistente'),
(3, 10, 'Pesquisador Júnior'),
(4, 11, 'Coordenador'),
(4, 12, 'Pesquisador Júnior'),
(4, 13, 'Pesquisador Sênior'),
(5, 14, 'Coordenador'),
(5, 15, 'Pesquisador Júnior'),
(5, 16, 'Pesquisador Sênior'),
(6, 17, 'Coordenador'),
(6, 18, 'Pesquisador Sênior'),
(6, 19, 'Pesquisador Júnior'),
(7, 20, 'Coordenador'),
(7, 21, 'Pesquisador Sênior'),
(7, 22, 'Pesquisador Júnior'),
(8, 23, 'Coordenador'),
(8, 24, 'Pesquisador Sênior'),
(8, 25, 'Pesquisador Júnior'),
(9, 26, 'Coordenador'),
(9, 27, 'Pesquisador Sênior'),
(9, 28, 'Pesquisador Júnior'),
(10, 29, 'Coordenador'),
(10, 1, 'Pesquisador Sênior'),
(10, 2, 'Pesquisador Júnior'),
(11, 3, 'Coordenador'),
(11, 4, 'Pesquisador Sênior'),
(11, 5, 'Pesquisador Júnior'),
(12, 6, 'Coordenador'),
(12, 7, 'Pesquisador Sênior'),
(12, 8, 'Pesquisador Júnior'),
(13, 9, 'Coordenador'),
(13, 10, 'Pesquisador Sênior'),
(13, 11, 'Pesquisador Júnior'),
(14, 12, 'Coordenador'),
(14, 13, 'Pesquisador Sênior'),
(14, 14, 'Pesquisador Júnior'),
(15, 15, 'Coordenador'),
(15, 16, 'Pesquisador Sênior'),
(15, 17, 'Pesquisador Júnior'),
(16, 18, 'Coordenador'),
(16, 19, 'Pesquisador Sênior'),
(16, 20, 'Pesquisador Júnior'),
(17, 21, 'Coordenador'),
(17, 22, 'Pesquisador Sênior'),
(17, 23, 'Pesquisador Júnior'),
(18, 24, 'Coordenador'),
(18, 25, 'Pesquisador Sênior'),
(18, 26, 'Pesquisador Júnior'),
(19, 27, 'Coordenador'),
(19, 28, 'Pesquisador Sênior'),
(19, 29, 'Pesquisador Júnior'),
(20, 30, 'Coordenador'),
(20, 1, 'Pesquisador Sênior'),
(20, 2, 'Pesquisador Júnior'),
(21, 3, 'Coordenador'),
(21, 4, 'Pesquisador Sênior'),
(21, 5, 'Pesquisador Júnior'),
(22, 6, 'Coordenador'),
(22, 7, 'Pesquisador Sênior'),
(22, 8, 'Pesquisador Júnior'),
(23, 9, 'Coordenador'),
(23, 10, 'Pesquisador Sênior'),
(23, 11, 'Pesquisador Júnior'),
(24, 12, 'Coordenador'),
(24, 13, 'Pesquisador Sênior'),
(24, 14, 'Pesquisador Júnior'),
(25, 15, 'Coordenador'),
(25, 16, 'Pesquisador Sênior'),
(25, 17, 'Pesquisador Júnior'),
(26, 18, 'Coordenador'),
(26, 19, 'Pesquisador Sênior'),
(26, 20, 'Pesquisador Júnior'),
(27, 21, 'Coordenador'),
(27, 22, 'Pesquisador Sênior'),
(27, 23, 'Pesquisador Júnior'),
(28, 24, 'Coordenador'),
(28, 25, 'Pesquisador Sênior'),
(28, 26, 'Pesquisador Júnior'),
(29, 27, 'Coordenador'),
(29, 28, 'Pesquisador Sênior'),
(29, 29, 'Pesquisador Júnior'),
(30, 30, 'Coordenador'),
(30, 1, 'Pesquisador Sênior'),
(30, 2, 'Pesquisador Júnior');




INSERT INTO Proposta (id_edital, id_projeto, data_submissao, status, avaliacao)
VALUES
(1, 3, '2024-08-01', 'Submetida', 'Avaliação preliminar da Plataforma de Inteligência Artificial para Saúde'),
(2, 5, '2024-08-15', 'Aprovada', 'Avaliação final da Análise de Big Data para Saúde Pública'),
(3, 7, '2024-09-01', 'Reprovada', 'Sistema de Monitoramento de Dados Urbanos para Cidades Inteligentes não atendeu aos critérios'),
(4, 2, '2024-09-05', 'Submetida', 'Avaliação preliminar do Chatbot Inteligente para Atendimento em Serviços Públicos'),
(5, 8, '2024-09-10', 'Aprovada', 'Análise de Sentimento em Redes Sociais aprovada com ressalvas'),
(6, 6, '2024-09-15', 'Reprovada', 'Blockchain para Gestão Segura de Dados Médicos não cumpriu os requisitos'),
(7, 9, '2024-09-20', 'Submetida', 'Avaliação preliminar do Diagnóstico Automatizado com IA em Imagens Médicas'),
(8, 1, '2024-09-25', 'Aprovada', 'Monitoramento de Bem-Estar de Idosos com Wearables aprovado com distinção'),
(9, 4, '2024-09-30', 'Reprovada', 'Plataforma de Recomendação de Tratamentos Médicos não atendeu aos critérios'),
(10, 10, '2024-10-01', 'Submetida', 'Avaliação preliminar da Integração de IA e Robótica para Reabilitação Física'),
(11, 12, '2024-10-05', 'Aprovada', 'Sistema de Monitoramento de Pacientes com IA em UTIs aprovado com recomendações'),
(12, 14, '2024-10-10', 'Reprovada', 'Análise de Dados para Prevenção de Doenças Crônicas não foi aceita'),
(13, 11, '2024-10-15', 'Submetida', 'Avaliação preliminar da IA para Previsão de Resultados Educacionais'),
(14, 17, '2024-10-20', 'Aprovada', 'Sistema de Reconhecimento Facial para Segurança aprovado com recomendação de financiamento'),
(15, 15, '2024-10-25', 'Reprovada', 'Automação de Processos em Governos Locais com IA não foi aceita'),
(16, 16, '2024-10-30', 'Submetida', 'Avaliação preliminar da Solução de IA para Triagem de Pacientes em Pronto Socorro'),
(17, 18, '2024-11-01', 'Aprovada', 'Data Analytics para Saúde Ocupacional aprovado com recomendação de ajustes'),
(18, 13, '2024-11-05', 'Reprovada', 'IA para Otimização de Estoques Hospitalares não foi aceita'),
(19, 20, '2024-11-10', 'Submetida', 'Avaliação preliminar da Plataforma de Apoio à Decisão para Políticas de Saúde Pública'),
(20, 21, '2024-11-15', 'Aprovada', 'Aplicação de Machine Learning para Fraudes aprovado com recomendação de execução'),
(21, 19, '2024-11-20', 'Reprovada', 'Sistema de Monitoramento de Pacientes com IA em UTIs não atendeu aos critérios'),
(22, 25, '2024-11-25', 'Submetida', 'Avaliação preliminar da IA para Detecção de Doenças Respiratórias'),
(23, 27, '2024-11-30', 'Aprovada', 'Plataforma de Gerenciamento de Dados Clínicos com Big Data aprovada com destaque'),
(24, 22, '2024-12-01', 'Reprovada', 'Chatbots com IA para Atendimento não foi aceito'),
(25, 24, '2024-12-05', 'Submetida', 'Avaliação preliminar da IA para Prevenção de Epidemias com Análise de Mobilidade'),
(26, 28, '2024-12-10', 'Aprovada', 'Plataforma de Telemedicina com IA aprovada com destaque'),
(27, 29, '2024-12-15', 'Reprovada', 'Solução de IA para Previsão de Demandas de Medicamentos não foi aceita'),
(28, 30, '2024-12-20', 'Submetida', 'Avaliação preliminar da Solução de Big Data para Análise de Dados Clínicos em Tempo Real');



INSERT INTO DespesaProjeto (id_projeto, descricao, valor, data)
VALUES
(1, 'Compra de Equipamentos', 15000.00, '2024-06-15'),
(2, 'Pagamento de Bolsas', 50000.00, '2024-07-01'),
(3, 'Compra de Materiais', 20000.00, '2024-08-10'),
(4, 'Contratação de Serviços', 30000.00, '2024-09-01'),
(5, 'Manutenção de Equipamentos', 10000.00, '2024-09-15'),
(6, 'Aquisição de Softwares', 40000.00, '2024-10-05'),
(7, 'Viagem para Conferências', 25000.00, '2024-10-20'),
(8, 'Publicação de Artigos', 12000.00, '2024-11-01'),
(9, 'Treinamento de Equipe', 18000.00, '2024-11-15'),
(10, 'Compra de Materiais de Escritório', 5000.00, '2024-12-01'),
(11, 'Serviços de Consultoria', 30000.00, '2024-12-15'),
(12, 'Contratação de Bolsistas', 20000.00, '2025-01-05'),
(13, 'Compra de Equipamentos de Laboratório', 35000.00, '2025-01-20'),
(14, 'Manutenção de Infraestrutura', 10000.00, '2025-02-01'),
(15, 'Viagens para Pesquisa de Campo', 20000.00, '2025-02-15'),
(16, 'Compra de Licenças de Software', 15000.00, '2025-03-01'),
(17, 'Contratação de Técnicos', 40000.00, '2025-03-10'),
(18, 'Aquisição de Materiais de Pesquisa', 25000.00, '2025-03-25'),
(19, 'Contratação de Serviços Externos', 20000.00, '2025-04-01'),
(20, 'Publicação de Resultados', 12000.00, '2025-04-15'),
(21, 'Compra de Ferramentas', 8000.00, '2025-05-01'),
(22, 'Pagamento de Inscrições em Conferências', 5000.00, '2025-05-10'),
(23, 'Desenvolvimento de Protótipos', 30000.00, '2025-05-25'),
(24, 'Consultoria Técnica', 20000.00, '2025-06-01'),
(25, 'Aquisição de Dados', 15000.00, '2025-06-10'),
(26, 'Publicação em Revistas Científicas', 10000.00, '2025-06-25'),
(27, 'Manutenção de Equipamentos de Pesquisa', 8000.00, '2025-07-05'),
(28, 'Contratação de Estagiários', 5000.00, '2025-07-15'),
(29, 'Compra de Licenças de Software', 15000.00, '2025-07-30'),
(30, 'Viagens para Pesquisa', 20000.00, '2025-08-10'),
(1, 'Compra de Equipamentos de TI', 25000.00, '2025-08-20'),
(2, 'Manutenção de Infraestrutura', 12000.00, '2025-09-01'),
(3, 'Contratação de Pessoal Temporário', 30000.00, '2025-09-10'),
(4, 'Aquisição de Materiais', 15000.00, '2025-09-20'),
(5, 'Serviços de Consultoria', 40000.00, '2025-10-01'),
(6, 'Pagamento de Licenças de Software', 18000.00, '2025-10-15'),
(7, 'Publicação de Livros', 12000.00, '2025-10-30'),
(8, 'Viagem para Eventos Científicos', 20000.00, '2025-11-05'),
(9, 'Desenvolvimento de Softwares', 35000.00, '2025-11-20'),
(10, 'Compra de Ferramentas', 10000.00, '2025-12-01'),
(11, 'Publicação de Artigos Científicos', 8000.00, '2025-12-15'),
(12, 'Contratação de Consultores Externos', 20000.00, '2026-01-05'),
(13, 'Aquisição de Dados para Pesquisa', 15000.00, '2026-01-20'),
(14, 'Manutenção de Equipamentos de TI', 5000.00, '2026-02-01'),
(15, 'Viagens para Coleta de Dados', 20000.00, '2026-02-15'),
(16, 'Contratação de Programadores', 35000.00, '2026-03-01'),
(17, 'Publicação em Revistas Científicas', 12000.00, '2026-03-10'),
(18, 'Compra de Ferramentas de TI', 18000.00, '2026-03-25'),
(19, 'Contratação de Analistas', 15000.00, '2026-04-01'),
(20, 'Publicação de Resultados de Pesquisa', 8000.00, '2026-04-10'),
(21, 'Compra de Equipamentos de Pesquisa', 25000.00, '2026-04-25'),
(22, 'Viagens para Apresentação de Resultados', 15000.00, '2026-05-01'),
(23, 'Serviços de Consultoria Técnica', 20000.00, '2026-05-15'),
(24, 'Publicação em Conferências Internacionais', 10000.00, '2026-05-30'),
(25, 'Aquisição de Softwares', 12000.00, '2026-06-01'),
(26, 'Desenvolvimento de Protótipos', 30000.00, '2026-06-15'),
(27, 'Contratação de Serviços Técnicos', 18000.00, '2026-06-30'),
(28, 'Compra de Equipamentos para Laboratório', 40000.00, '2026-07-05'),
(29, 'Manutenção de Infraestrutura de TI', 10000.00, '2026-07-15'),
(30, 'Viagens para Conferências Internacionais', 25000.00, '2026-07-30');
