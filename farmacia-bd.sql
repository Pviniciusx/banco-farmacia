CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(150)
);

INSERT INTO categoria (nome, descricao) 
VALUES ('Analgesicos e Antitermicos', 'Medicamentos para dores e febre'),
('Antibioticos', 'Antimicrobianos (sujeitos a retenção de receita)'),
('Anti-inflamatorios', 'Controle inflamatorio e dores musculares'),
('Cardiovasculares', 'Medicamentos de uso continuo (hipertensão e coração)'),
('Dermatologicos', 'Pomadas, cremes e loções medicinais'),
('Gastrointestinais', 'Antiacidos, anti-ulcerosos e digestivos'),
('Antialergicos', 'Anti-histaminicos (para reações alergicas e rinite)'),
('Vitaminas e Suplementos', 'Polivitaminicos e suplementação mineral'),
('Higiene Pessoal', 'Sabonetes, cremes dentais e cuidados diarios'),
('Primeiros Socorros', 'Curativos, gases, antissépticos e algodão');

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    email VARCHAR(100),
    data_nascimento DATE
);

INSERT INTO cliente (nome, cpf, telefone, data_nascimento) 
VALUES ('Carlos Eduardo Silva', '12345678901', '17991112233', '1985-03-12'),
('Mariana Souza Santos', '23456789012', '17992223344', '1992-07-25'),
('Lucas Gabriel Pereira', '34567890123', '17993334455', '2001-11-18'),
('Fernanda Cristina Dias', '45678901234', '17994445566', '1979-05-04'),
('Roberto de Almeida', '56789012345', '17995556677', '1968-09-30'),
('Camila Rodrigues Lima', '67890123456', '17996667788', '1995-02-14'),
('Bruno Henrique Martins', '78901234567', '17997778899', '1988-12-08'),
('Juliana Barbosa Castro', '89012345678', '17998889900', '1999-04-21'),
('Marcos Vinicius Faria', '90123456789', '17991234567', '1973-10-15'),
('Patricia Regina Gomes', '01234567890', '17992345678', '1982-08-03');

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

DROP TABLE produto; 

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

INSERT INTO produto (id_categoria, nome_comercial, principio_ativo, concentracao, preco_unitario, estoque_atual, requer_receita) 
VALUES (1, 'Dipirona Monoidratada', 'Dipirona', '500mg/ml', 6.50, 150, FALSE),
(1, 'Paracetamol Gotas', 'Paracetamol', '200mg/ml', 8.20, 110, FALSE),
(2, 'Amoxicilina', 'Amoxicilina Tri-hidratada', '500mg', 28.90, 45, TRUE),
(2, 'Azitromicina', 'Azitromicina Di-hidratada', '500mg', 34.50, 30, TRUE),
(3, 'Ibuprofeno', 'Ibuprofeno', '600mg', 16.00, 85, FALSE),
(4, 'Losartana Potássica', 'Losartana Potássica', '50mg', 11.80, 200, FALSE),
(6, 'Omeprazol', 'Omeprazol Magnésico', '20mg', 19.90, 90, FALSE),
(7, 'Loratadina', 'Loratadina', '10mg', 14.30, 75, FALSE),
(8, 'Vitamina C Efervescente', 'Ácido Ascórbico', '1g', 18.00, 60, FALSE),
(10, 'Álcool 70% Líquido', 'Álcool Etílico', '1000ml', 9.50, 80, FALSE);

CREATE TABLE venda (
    id_venda SERIAL PRIMARY KEY,
    id_cliente INT,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10, 2) NOT NULL,
    forma_pagamento VARCHAR(20) NOT NULL,
    CONSTRAINT fk_venda_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

INSERT INTO venda (id_cliente, valor_total, forma_pagamento) 
VALUES (1, 32.50, 'PIX'),
(2, 34.50, 'CARTAO_CREDITO'),
(3, 16.00, 'DINHEIRO'),
(4, 39.80, 'CARTAO_DEBITO'),
(5, 23.60, 'PIX'),
(6, 28.90, 'CARTAO_CREDITO'),
(7, 24.50, 'DINHEIRO'),
(8, 18.00, 'PIX'),
(9, 19.00, 'CARTAO_DEBITO'),
(10, 37.90, 'PIX');

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

INSERT INTO item_venda (id_venda, id_produto, quantidade, preco_praticado, subtotal) 
VALUES (1, 1, 1, 6.50, 6.50),
(1, 3, 1, 26.00, 26.00),
(2, 4, 1, 34.50, 34.50),
(3, 5, 1, 16.00, 16.00),
(4, 7, 2, 19.90, 39.80),
(5, 6, 2, 11.80, 23.60),
(6, 3, 1, 28.90, 28.90),
(7, 2, 1, 8.20, 8.20),
(7, 8, 1, 16.30, 16.30),
(8, 9, 1, 18.00, 18.00);

ALTER TABLE cliente ADD COLUMN status_cadastro VARCHAR(20) DEFAULT 'Ativo';

ALTER TABLE produto RENAME COLUMN preco_unitario TO preco_venda;

UPDATE produto 
SET preco_venda = 22.50 
WHERE nome_comercial = 'Omeprazol';

UPDATE cliente 
SET email = 'carlos.eduardo.silva@novoemail.com' 
WHERE id_cliente = 1;

INSERT INTO produto (id_categoria, nome_comercial, principio_ativo, concentracao, preco_venda, estoque_atual, requer_receita) 
VALUES (1, 'Remedio Teste', 'Teste', '10mg', 5.00, 0, FALSE);

DELETE FROM produto 
WHERE nome_comercial = 'Remedio Teste';