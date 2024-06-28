-- Exercicio 1 de Trigger e Function
-- Contexto: Ao modificar o salario de um funcionario, é preciso registrar a modificação na base de dados de auditoria de funcionarios
-- Esse exemplo cria uma infraestrutura completa para monitorar as alterações de salário, garantindo que qualquer ajuste seja devidamente registrado, oferecendo uma trilha de auditoria clara e útil para análises futuras.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- extencao para deixar o id como hash

-- Criando tabelas para o exemplo de trigger
-- Objetivo: Ao alterar o salario em funcionario, termos o gatilho para inserir na tabela de auditoria os valores alterados
CREATE TABLE IF NOT EXISTS funcionario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100),
    salario DECIMAL(10, 2),
    dt_contratacao DATE
);

CREATE TABLE IF NOT EXISTS funcionario_auditoria (
    id UUID,
    salario_antigo DECIMAL(10, 2),
    novo_salario DECIMAL(10, 2),
    data_modificacao_do_salario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES funcionario(id)
);

-- Inserindo os funcionarios
INSERT INTO funcionario (nome, salario, dt_contratacao) VALUES ('Maria', 5000.00, '2021-06-01');
INSERT INTO funcionario (nome, salario, dt_contratacao) VALUES ('João', 4500.00, '2021-07-15');
INSERT INTO funcionario (nome, salario, dt_contratacao) VALUES ('Ana', 4000.00, '2022-01-10');
INSERT INTO funcionario (nome, salario, dt_contratacao) VALUES ('Pedro', 5500.00, '2022-03-20');
INSERT INTO funcionario (nome, salario, dt_contratacao) VALUES ('Lucas', 4700.00, '2022-05-25');

-- Criando Trigger e Function: 
-- Objetivo: Sempre que tiver um update de salario na tabela funcionario, irá atualizar na funcionario_auditoria
CREATE FUNCTION registrar_auditoria_salario()
RETURNS TRIGGER
AS $$
BEGIN
    INSERT INTO funcionario_auditoria (id, salario_antigo, novo_salario)
    VALUES (OLD.id, OLD.salario, NEW.salario);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_salario_modificado
AFTER UPDATE OF salario ON funcionario
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_salario();

-- TESTE atualizando o salario de funcionario
UPDATE funcionario SET salario = 4500.00
WHERE id = '861df9f3-3a09-4d75-95a1-41ec0b65776c' -- Selecione o id do funcionario

SELECT * FROM funcionario_auditoria -- Modificação de salario aparecerá na auditoria