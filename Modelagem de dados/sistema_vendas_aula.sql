-- Aula de Modelagem de Dados e SQL
-- Sistema de Vendas - 3o ano de Desenvolvimento de Sistemas
-- MySQL 8+

-- =========================================================
-- 1. DDL - CRIACAO DO BANCO E DAS TABELAS
-- =========================================================

CREATE DATABASE IF NOT EXISTS sistema_vendas_3ds
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE sistema_vendas_3ds;

-- Ordem de DROP pensada para respeitar as chaves estrangeiras.
DROP TABLE IF EXISTS vendas;
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  telefone VARCHAR(20),
  cpf CHAR(11) NOT NULL UNIQUE,
  data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL UNIQUE,
  descricao VARCHAR(255)
);

CREATE TABLE produtos (
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  id_categoria INT NOT NULL,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(255),
  preco DECIMAL(10,2) NOT NULL,
  estoque INT NOT NULL DEFAULT 0,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_produtos_preco CHECK (preco >= 0),
  CONSTRAINT chk_produtos_estoque CHECK (estoque >= 0),
  CONSTRAINT fk_produtos_categorias
    FOREIGN KEY (id_categoria)
    REFERENCES categorias(id_categoria)
);

CREATE TABLE pedidos (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status_pedido ENUM('ABERTO', 'PAGO', 'CANCELADO', 'ENTREGUE') NOT NULL DEFAULT 'ABERTO',
  observacao VARCHAR(255),
  CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (id_cliente)
    REFERENCES clientes(id_cliente)
);

CREATE TABLE itens_pedido (
  id_item_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT chk_itens_quantidade CHECK (quantidade > 0),
  CONSTRAINT chk_itens_preco CHECK (preco_unitario >= 0),
  CONSTRAINT chk_itens_desconto CHECK (desconto >= 0),
  CONSTRAINT uq_itens_pedido_produto UNIQUE (id_pedido, id_produto),
  CONSTRAINT fk_itens_pedidos
    FOREIGN KEY (id_pedido)
    REFERENCES pedidos(id_pedido)
    ON DELETE CASCADE,
  CONSTRAINT fk_itens_produtos
    FOREIGN KEY (id_produto)
    REFERENCES produtos(id_produto)
);

CREATE TABLE vendas (
  id_venda INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL UNIQUE,
  data_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  forma_pagamento ENUM('DINHEIRO', 'PIX', 'CARTAO_CREDITO', 'CARTAO_DEBITO') NOT NULL,
  valor_total DECIMAL(10,2) NOT NULL,
  CONSTRAINT chk_vendas_valor_total CHECK (valor_total >= 0),
  CONSTRAINT fk_vendas_pedidos
    FOREIGN KEY (id_pedido)
    REFERENCES pedidos(id_pedido)
);

-- =========================================================
-- 2. DML - INSERCAO DE DADOS
-- =========================================================

INSERT INTO clientes (nome, email, telefone, cpf) VALUES
('Ana Souza', 'ana.souza@email.com', '11988880001', '11122233344'),
('Bruno Lima', 'bruno.lima@email.com', '11988880002', '22233344455'),
('Carla Mendes', 'carla.mendes@email.com', '11988880003', '33344455566'),
('Diego Alves', 'diego.alves@email.com', '11988880004', '44455566677'),
('Eduarda Rocha', 'eduarda.rocha@email.com', '11988880005', '55566677788');

INSERT INTO categorias (nome, descricao) VALUES
('Eletronicos', 'Produtos tecnologicos e acessorios'),
('Papelaria', 'Materiais escolares e de escritorio'),
('Informatica', 'Itens de hardware e perifericos');

INSERT INTO produtos (id_categoria, nome, descricao, preco, estoque) VALUES
(1, 'Fone Bluetooth', 'Fone sem fio com microfone', 129.90, 30),
(1, 'Carregador USB-C', 'Carregador rapido 25W', 79.90, 50),
(2, 'Caderno 10 materias', 'Caderno universitario', 34.90, 100),
(2, 'Caneta Azul', 'Caneta esferografica azul', 2.50, 300),
(3, 'Mouse Gamer', 'Mouse com 6 botoes e RGB', 149.90, 20);

INSERT INTO pedidos (id_cliente, data_pedido, status_pedido, observacao) VALUES
(1, '2026-04-10 09:30:00', 'PAGO', 'Cliente retirou na loja'),
(2, '2026-04-11 14:20:00', 'ABERTO', 'Aguardando pagamento'),
(3, '2026-04-12 16:45:00', 'PAGO', 'Entrega agendada');

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, desconto) VALUES
(1, 1, 1, 129.90, 0.00),
(1, 4, 3, 2.50, 0.00),
(2, 3, 2, 34.90, 5.00),
(2, 4, 5, 2.50, 0.00),
(3, 2, 1, 79.90, 0.00),
(3, 5, 1, 149.90, 10.00);

INSERT INTO vendas (id_pedido, data_venda, forma_pagamento, valor_total) VALUES
(1, '2026-04-10 09:45:00', 'PIX', 137.40),
(3, '2026-04-12 17:10:00', 'CARTAO_CREDITO', 219.80);

-- =========================================================
-- 3. DQL - CONSULTAS PARA ENTENDER OS COMANDOS DE BUSCA
-- =========================================================

-- 3.1 Listar todos os clientes.
SELECT *
FROM clientes;

-- 3.2 Mostrar apenas nome e email dos clientes, ordenados alfabeticamente.
SELECT nome, email
FROM clientes
ORDER BY nome ASC;

-- 3.3 Buscar um cliente pelo nome usando LIKE.
SELECT id_cliente, nome, email
FROM clientes
WHERE nome LIKE '%Ana%';

-- 3.4 Listar produtos com preco maior que R$ 50,00.
SELECT nome, preco, estoque
FROM produtos
WHERE preco > 50.00
ORDER BY preco DESC;

-- 3.5 Listar produtos e suas categorias.
SELECT
  p.id_produto,
  p.nome AS produto,
  c.nome AS categoria,
  p.preco,
  p.estoque
FROM produtos p
INNER JOIN categorias c
  ON p.id_categoria = c.id_categoria
ORDER BY c.nome, p.nome;

-- 3.6 Listar pedidos com nome do cliente.
SELECT
  pe.id_pedido,
  cl.nome AS cliente,
  pe.data_pedido,
  pe.status_pedido
FROM pedidos pe
INNER JOIN clientes cl
  ON pe.id_cliente = cl.id_cliente
ORDER BY pe.data_pedido;

-- 3.7 Listar itens de um pedido especifico.
SELECT
  pe.id_pedido,
  pr.nome AS produto,
  ip.quantidade,
  ip.preco_unitario,
  ip.desconto,
  (ip.quantidade * ip.preco_unitario - ip.desconto) AS subtotal
FROM itens_pedido ip
INNER JOIN pedidos pe
  ON ip.id_pedido = pe.id_pedido
INNER JOIN produtos pr
  ON ip.id_produto = pr.id_produto
WHERE pe.id_pedido = 1;

-- 3.8 Calcular o total de cada pedido a partir dos itens.
SELECT
  pe.id_pedido,
  cl.nome AS cliente,
  SUM(ip.quantidade * ip.preco_unitario - ip.desconto) AS total_calculado
FROM pedidos pe
INNER JOIN clientes cl
  ON pe.id_cliente = cl.id_cliente
INNER JOIN itens_pedido ip
  ON pe.id_pedido = ip.id_pedido
GROUP BY pe.id_pedido, cl.nome
ORDER BY pe.id_pedido;

-- 3.9 Listar apenas pedidos pagos.
SELECT id_pedido, id_cliente, data_pedido, status_pedido
FROM pedidos
WHERE status_pedido = 'PAGO';

-- 3.10 Listar vendas com cliente, forma de pagamento e valor total.
SELECT
  v.id_venda,
  cl.nome AS cliente,
  v.data_venda,
  v.forma_pagamento,
  v.valor_total
FROM vendas v
INNER JOIN pedidos pe
  ON v.id_pedido = pe.id_pedido
INNER JOIN clientes cl
  ON pe.id_cliente = cl.id_cliente
ORDER BY v.data_venda;

-- 3.11 Contar quantos produtos existem em cada categoria.
SELECT
  c.nome AS categoria,
  COUNT(p.id_produto) AS quantidade_produtos
FROM categorias c
LEFT JOIN produtos p
  ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nome;

-- 3.12 Procurar produtos por faixa de preco.
SELECT nome, preco
FROM produtos
WHERE preco BETWEEN 10.00 AND 150.00
ORDER BY preco;

-- 3.13 Listar clientes que ainda nao possuem pedido.
SELECT cl.id_cliente, cl.nome
FROM clientes cl
LEFT JOIN pedidos pe
  ON cl.id_cliente = pe.id_cliente
WHERE pe.id_pedido IS NULL;

-- 3.14 Atualizar o estoque depois de uma venda.
-- Exemplo: produto 1 vendeu 1 unidade.
UPDATE produtos
SET estoque = estoque - 1
WHERE id_produto = 1 AND estoque >= 1;

-- 3.15 Remover um item de um pedido.
-- Cuidado: DELETE altera os dados. Use apenas em ambiente de treino.
DELETE FROM itens_pedido
WHERE id_item_pedido = 4;
