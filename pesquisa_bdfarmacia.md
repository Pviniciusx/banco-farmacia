# Banco de Dados: Farmácia (PostgreSQL)

## 1. Contexto Descritivo

O sistema destina-se à gestão operacional de uma drogaria, cobrindo o controle de estoque, catalogação de produtos farmacêuticos, registro de clientes e emissão de vendas com seus respectivos itens.

* **Categorias:** Os produtos são agrupados por categorias terapêuticas ou comerciais (ex.: Analgésicos, Antibióticos) para facilitar a busca e a organização do estoque.
* **Produtos / Medicamentos:** Cada produto possui código identificador, nome comercial, princípio ativo, dosagem, preço de venda, quantidade em estoque, flag de retenção de receita médica e vínculo direto com uma única categoria.
* **Clientes:** A farmácia cadastra clientes para fidelização, histórico de compras e controle de medicamentos controlados.
* **Vendas:** Uma venda registra o momento em que o cliente adquire itens, a data/hora, a forma de pagamento e o valor final.
* **Itens da Venda:** Relacionamento associativo entre a venda e o produto, armazenando a quantidade comercializada, o preço unitário praticado na transação e o subtotal.



## 2. Fontes de Dados

Os dados inseridos no projeto (categorias e produtos) foram modelados com base no padrão real do varejo farmacêutico brasileiro e em conhecimentos gerais de farmacologia, embasados por:

* **ANVISA (Agência Nacional de Vigilância Sanitária):** Utilizada como base para a regra de negócio da coluna `requer_receita`. A agência define medicamentos controlados (que exigem retenção de receita) e Medicamentos Isentos de Prescrição (MIPs).
* **Bulário Eletrônico da ANVISA:** Referência técnica para a nomenclatura dos princípios ativos e concentrações reais comercializadas no mercado.
* **Práticas de Gestão de Categorias (Varejo):** A divisão entre categorias terapêuticas e de conveniência reflete o plano de contas padrão de sistemas de gestão (ERPs) de drogarias comerciais.



## 3. Modelo Relacional e Mapeamento (DER Lógico)

### Entidades e Atributos

#### CATEGORIA

* `id_categoria` (SERIAL, PK)
* `nome` (VARCHAR(50), Not Null, Unique)
* `descricao` (VARCHAR(150))



#### CLIENTE

* `id_cliente` (SERIAL, PK)
* `nome` (VARCHAR(100), Not Null)
* `cpf` (CHAR(11), Not Null, Unique)
* `telefone` (VARCHAR(15))
* `email` (VARCHAR(100))
* `data_nascimento` (DATE)



#### PRODUTO

* `id_produto` (SERIAL, PK)
* `id_categoria` (INT, FK referenciando CATEGORIA)
* `nome_comercial` (VARCHAR(100), Not Null)
* `principio_ativo` (VARCHAR(100))
* `concentracao` (VARCHAR(30))
* `preco_unitario` (DECIMAL(10,2), Not Null)
* `estoque_atual` (INT, Not Null)
* `requer_receita` (BOOLEAN, Not Null, Default FALSE)



#### VENDA

* `id_venda` (SERIAL, PK)
* `id_cliente` (INT, FK referenciando CLIENTE, Null)
* `data_hora` (TIMESTAMP, Not Null)
* `valor_total` (DECIMAL(10,2), Not Null)
* `forma_pagamento` (VARCHAR(20), Not Null)



#### ITEM_VENDA

* `id_item` (SERIAL, PK)
* `id_venda` (INT, FK referenciando VENDA)
* `id_produto` (INT, FK referenciando PRODUTO)
* `quantidade` (INT, Not Null)
* `preco_praticado` (DECIMAL(10,2), Not Null)
* `subtotal` (DECIMAL(10,2), Not Null)



### Cardinalidades

* `CATEGORIA (1,1) --- (0,N) PRODUTO`: Uma categoria pode conter zero ou muitos produtos; um produto pertence obrigatoriamente a uma única categoria.
* `CLIENTE (0,1) --- (0,N) VENDA`: Um cliente cadastrado pode realizar zero ou muitas compras; uma venda pode estar associada a um cliente ou ser anônima.
* `VENDA (1,1) --- (1,N) ITEM_VENDA`: Uma venda contém obrigatoriamente um ou muitos itens; um item pertence a uma única venda.
* `PRODUTO (0,1) --- (0,N) ITEM_VENDA`: Um produto pode aparecer em zero ou muitos itens de venda; cada item de venda referencia um único produto.



## 4. Scripts DDL, DML e Alterações (PostgreSQL)

```sql
-- 1. CATEGORIA
CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(150)
);

INSERT INTO categoria (nome, descricao) VALUES
('Analgesicos e Antitermicos', 'Medicamentos para dores e febre'),
('Antibioticos', 'Antimicrobianos (sujeitos a retenção de receita)'),
('Anti-inflamatorios', 'Controle inflamatorio e dores musculares'),
('Cardiovasculares', 'Medicamentos de uso continuo (hipertensão e coração)'),
('Dermatologicos', 'Pomadas, cremes e loções medicinais'),
('Gastrointestinais', 'Antiacidos, anti-ulcerosos e digestivos'),
('Antialergicos', 'Anti-histaminicos (para reações alergicas e rinite)'),
('Vitaminas e Suplementos', 'Polivitaminicos e suplementação mineral'),
('Higiene Pessoal', 'Sabonetes, cremes dentais e cuidados diarios'),
('Primeiros Socorros', 'Curativos, gases, antissépticos e algodão');

-- 2. CLIENTE
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    email VARCHAR(100),
    data_nascimento DATE
);

INSERT INTO cliente (nome, cpf, telefone, data_nascimento) VALUES
('Carlos Eduardo Silva', '12345678901', '17991112233', '1985-03-12'),
('Mariana Souza Santos', '23456789012', '17992223344', '1992-07-25'),
('Lucas Gabriel Pereira', '34567890123', '17993334455', '2001-11-18'),
('Fernanda Cristina Dias', '45678901234', '17994445566', '1979-05-04'),
('Roberto de Almeida', '56789012345', '17995556677', '1968-09-30'),
('Camila Rodrigues Lima', '67890123456', '17996667788', '1995-02-14'),
('Bruno Henrique Martins', '78901234567', '17997778899', '1988-12-08'),
('Juliana Barbosa Castro', '89012345678', '17998889900', '1999-04-21'),
('Marcos Vinicius Faria', '90123456789', '17991234567', '1973-10-15'),
('Patricia Regina Gomes', '01234567890', '17992345678', '1982-08-03');

-- 3. PRODUTO (com simulação de exclusão acidental e recriação)
CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_comercial VARCHAR(100) NOT NULL,
    principio_ativo VARCHAR(100),
    concentracao VARCHAR(30),
    preco_unitario DECIMAL(10, 2) NOT NULL,
    estoque_atual INT NOT NULL,
    requer_receita BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- Simulação: Tabela criada incorretamente ou precisando de reestruturação drástica
DROP TABLE produto; -- Recriando a tabela corretamente (neste cenário, seria igual, mas demonstra o DROP)

CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_comercial VARCHAR(100) NOT NULL,
    principio_ativo VARCHAR(100),
    concentracao VARCHAR(30),
    preco_unitario DECIMAL(10, 2) NOT NULL,
    estoque_atual INT NOT NULL,
    requer_receita BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

INSERT INTO produto (id_categoria, nome_comercial, principio_ativo, concentracao, preco_unitario, estoque_atual, requer_receita) VALUES
(1, 'Dipirona Monoidratada', 'Dipirona', '500mg/ml', 6.50, 150, FALSE),
(1, 'Paracetamol Gotas', 'Paracetamol', '200mg/ml', 8.20, 110, FALSE),
(2, 'Amoxicilina', 'Amoxicilina Tri-hidratada', '500mg', 28.90, 45, TRUE),
(2, 'Azitromicina', 'Azitromicina Di-hidratada', '500mg', 34.50, 30, TRUE),
(3, 'Ibuprofeno', 'Ibuprofeno', '600mg', 16.00, 85, FALSE),
(4, 'Losartana Potássica', 'Losartana Potássica', '50mg', 11.80, 200, FALSE),
(6, 'Omeprazol', 'Omeprazol Magnésico', '20mg', 19.90, 90, FALSE),
(7, 'Loratadina', 'Loratadina', '10mg', 14.30, 75, FALSE),
(8, 'Vitamina C Efervescente', 'Ácido Ascórbico', '1g', 18.00, 60, FALSE),
(10, 'Álcool 70% Líquido', 'Álcool Etílico', '1000ml', 9.50, 80, FALSE);

-- 4. VENDA
CREATE TABLE venda (
    id_venda SERIAL PRIMARY KEY,
    id_cliente INT,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10, 2) NOT NULL,
    forma_pagamento VARCHAR(20) NOT NULL,
    CONSTRAINT fk_venda_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

INSERT INTO venda (id_cliente, valor_total, forma_pagamento) VALUES
(1, 32.50, 'PIX'),
(2, 34.50, 'CARTAO_CREDITO'),
(3, 16.00, 'DINHEIRO'),
(4, 39.80, 'CARTAO_DEBITO'),
(5, 23.60, 'PIX'),
(6, 28.90, 'CARTAO_CREDITO'),
(7, 24.50, 'DINHEIRO'),
(8, 18.00, 'PIX'),
(9, 19.00, 'CARTAO_DEBITO'),
(10, 37.90, 'PIX');

-- 5. ITEM_VENDA
CREATE TABLE item_venda (
    id_item SERIAL PRIMARY KEY,
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_praticado DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_item_venda FOREIGN KEY (id_venda) REFERENCES venda(id_venda),
    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

INSERT INTO item_venda (id_venda, id_produto, quantidade, preco_praticado, subtotal) VALUES
(1, 1, 1, 6.50, 6.50),
(1, 3, 1, 26.00, 26.00),
(2, 4, 1, 34.50, 34.50),
(3, 5, 1, 16.00, 16.00),
(4, 7, 2, 19.90, 39.80),
(5, 6, 2, 11.80, 23.60),
(6, 3, 1, 28.90, 28.90),
(7, 2, 1, 8.20, 8.20),
(7, 8, 1, 16.30, 16.30),
(8, 9, 1, 18.00, 18.00);

-- 5. DEMONSTRAÇÃO DE MANUTENÇÃO (ALTER, UPDATE, DELETE)

-- a. ALTER TABLE: Adicionando uma nova coluna na tabela de clientes
ALTER TABLE cliente ADD COLUMN status_cadastro VARCHAR(20) DEFAULT 'Ativo';

-- b. ALTER TABLE (RENAME): Renomeando uma coluna na tabela de produtos
ALTER TABLE produto RENAME COLUMN preco_unitario TO preco_venda;

-- c. UPDATE: Atualizando o preço de um produto específico (aumento no Omeprazol)
UPDATE produto SET preco_venda = 22.50 WHERE nome_comercial = 'Omeprazol';

-- d. UPDATE: Corrigindo o e-mail de um cliente
UPDATE cliente SET email = 'carlos.eduardo.silva@novoemail.com' WHERE id_cliente = 1;

-- e. DELETE: Removendo um produto do estoque que saiu de linha
-- (Supondo que não haja vendas vinculadas, caso contrário violaria a FK)
-- Vamos inserir um produto fake primeiro para poder deletar
INSERT INTO produto (id_categoria, nome_comercial, principio_ativo, concentracao, preco_venda, estoque_atual, requer_receita) VALUES
(1, 'Remedio Teste', 'Teste', '10mg', 5.00, 0, FALSE);

DELETE FROM produto WHERE nome_comercial = 'Remedio Teste';
```[cite: 1]

## 5 – Fontes da Pesquisa

* **Portal da ANVISA:** Página oficial com as regulamentações sanitárias e regras de negócio sobre quais medicamentos são isentos de prescrição (MIPs) e quais exigem retenção de receita. Link: [https://www.gov.br/anvisa/](https://www.gov.br/anvisa/)
* **Bulário Eletrônico da ANVISA:** Sistema oficial de consultas do governo usado para extrair a nomenclatura técnica exata dos princípios ativos e as concentrações reais de mercado (ex: 500mg, 20mg). Link: [https://consultas.anvisa.gov.br/#/bulario/](https://consultas.anvisa.gov.br/#/bulario/)
* **Manual de Gerenciamento por Categoria (SEBRAE):** Documento focado na estruturação do varejo farmacêutico, que detalha a divisão dos produtos em categorias comerciais, terapêuticas e de conveniência (como higiene e primeiros socorros). Link: [https://bibliotecas.sebrae.com.br/bis/download.zhtml?t=D&uid=1bd656fa216418f28e85def5a56ef976](https://bibliotecas.sebrae.com.br/bis/download.zhtml?t=D&uid=1bd656fa216418f28e85def5a56ef976)
* **Guia da Farmácia (Gestão de Categorias):** Portal especializado com diretrizes de como organizar os departamentos e categorias da farmácia dentro de sistemas de gestão (ERPs) para maximizar as vendas e organizar o estoque. Link: [https://guiadafarmacia.com.br/gestao-de-categorias-em-farmacia/](https://guiadafarmacia.com.br/gestao-de-categorias-em-farmacia/)[cite: 1]

```