USE master
GO
--DROP DATABASE exQueryDinamica
CREATE DATABASE exQueryDinamica
GO
USE exQueryDinamica 

GO
CREATE TABLE produto(
codigo		INT          NOT NULL,
nome        VARCHAR(40)  NOT NULL,
valor       DECIMAL(7,2) NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE entrada (
codigoTransacao  INT	NOT NULL, 
codigoProduto    INT    NOT NULL,
quantidade		 INT	NOT NULL,
valorTotal		 INT    NOT NULL
PRIMARY KEY (codigoTransacao)
FOREIGN KEY (codigoProduto) REFERENCES produto(codigo)
)
GO
CREATE TABLE saida (
codigoTransacao  INT	NOT NULL, 
codigoProduto    INT    NOT NULL,
quantidade		 INT	NOT NULL,
valorTotal		 INT    NOT NULL
PRIMARY KEY (codigoTransacao)
FOREIGN KEY (codigoProduto) REFERENCES produto(codigo)
)
GO

SELECT * FROM produto
SELECT * FROM entrada
SELECT * FROM saida

SELECT p.codigo, p.nome, p.valor
FROM entrada t, produto p
WHERE p.codigo = t.codigoProduto
 
SELECT p.codigo, p.nome, p.valor
FROM saida s, produto p
WHERE p.codigo = s.codigoProduto
 
--Exemplo de Query Dinâminca
DECLARE @query	VARCHAR(200),
		@codigo		INT,
		@nome	VARCHAR(40),
		@valor	DECIMAL(7,2)
SET @codigo = 1
SET @nome = 'Notebook Lenovo'
SET @valor = 1.500
/*Query Dinâmica*/
SET @query = 'INSERT INTO produto VALUES ('+CAST(@codigo AS VARCHAR(5))
				+','''+ @nome + ''', ' + CAST(@valor AS VARCHAR(10)) + ')'
PRINT @query
EXEC (@query) 

CREATE PROCEDURE sp_insereTransacao (
    @codigo CHAR(1),
    @codigoTransacao INT,
    @codigoProduto INT,
    @quantidade INT,
    @erro VARCHAR(100) OUTPUT
)
AS
BEGIN
    DECLARE @valorTotal DECIMAL(7,2)
    
    -- Verifica se o código é válido ('e' para entrada ou 's' para saída)
    IF @codigo NOT IN ('e', 's')
    BEGIN
        SET @erro = 'Código inválido.'
        RETURN
    END
    
    -- Calcula o valor total da transação
    SET @valorTotal = (SELECT valor * @quantidade FROM produto WHERE codigo = @codigoProduto)
    
    -- Insere na tabela de entrada se o código for 'e', senão, insere na tabela de saída
    IF @codigo = 'e'
    BEGIN
        INSERT INTO entrada (codigoTransacao, codigoProduto, quantidade, valorTotal)
        VALUES (@codigoTransacao, @codigoProduto, @quantidade, @valorTotal)
    END
    ELSE
    BEGIN
        INSERT INTO saida (codigoTransacao, codigoProduto, quantidade, valorTotal)
        VALUES (@codigoTransacao, @codigoProduto, @quantidade, @valorTotal)
    END
    SET @erro = NULL
END

DECLARE @out1 VARCHAR(100)
EXEC sp_insereTransacao 'e', 1, 1, 5, @out1 OUTPUT
PRINT @out1

DECLARE @out2 VARCHAR(100)
EXEC sp_insereTransacao 's', 2, 2, 3, @out2 OUTPUT
PRINT @out2

