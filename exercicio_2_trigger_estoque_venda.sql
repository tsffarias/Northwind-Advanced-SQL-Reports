-- Exercicio 2 de Trigger e Function
-- Contexto: Neste exercício, você irá implementar um sistema simples de gestão de estoque para uma loja que vende camisetas como Basica, Dados e Verao. A loja precisa garantir que as vendas sejam registradas apenas se houver estoque suficiente para atender os pedidos. Você será responsável por criar um trigger no banco de dados que previna a inserção de vendas que excedam a quantidade disponível dos produtos.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- extencao para deixar o id como hash

-- Criando tabelas para o exemplo de trigger
CREATE TABLE IF NOT EXISTS produto (
    cod_prod UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    descricao VARCHAR(50) UNIQUE,
    qtde_disponivel INT NOT NULL DEFAULT 0,
    dt_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registro_vendas (
    cod_venda UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cod_prod UUID,
    qtde_vendida INT,
    FOREIGN KEY (cod_prod) REFERENCES produto (cod_prod)
);

-- Inserindo Produtos
INSERT INTO produto(descricao, qtde_disponivel) VALUES ('Basica', 10);
INSERT INTO produto(descricao, qtde_disponivel) VALUES ('Dados', 5);
INSERT INTO produto(descricao, qtde_disponivel) VALUES ('Verao', 15);

-- Criando Trigger e Function
CREATE OR REPLACE FUNCTION func_verifica_estoque()
RETURNS TRIGGER AS $$
DECLARE 
    qted_atual INTEGER;
BEGIN
    -- Seleciona a quantidade disponível do produto
    SELECT qtde_disponivel INTO qted_atual
    FROM produto 
    WHERE cod_prod = NEW.cod_prod;
    
    -- Verifica se a quantidade disponível é menor que a quantidade vendida
    IF qted_atual < NEW.qtde_vendida THEN
        RAISE EXCEPTION 'Quantidade indisponível em estoque';
    ELSE
        -- Atualiza a quantidade disponível do produto
        UPDATE produto 
        SET qtde_disponivel = qtde_disponivel - NEW.qtde_vendida
        WHERE cod_prod = NEW.cod_prod;

        -- Diagnóstico para verificar se a atualização foi executada
        RAISE NOTICE 'Produto atualizado: % - Quantidade disponível: %', NEW.cod_prod, qted_atual - NEW.qtde_vendida;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verifica_estoque
BEFORE INSERT ON registro_vendas
FOR EACH ROW 
EXECUTE FUNCTION func_verifica_estoque();

-- TESTE
select * from produto -- pegue um cod_prod
INSERT INTO registro_vendas(cod_prod, qtde_vendida) VALUES ('e069973f-1a30-4f93-913f-d9f45f971223', 5);
select * from registro_vendas