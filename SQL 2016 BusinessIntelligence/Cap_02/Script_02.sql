-- Laborat�rio 1
EXEC sp_attach_db 
 @dbname    = 'PEDIDOS',   
 @filename1 = 'c:\Dados\PEDIDOS_TABELAS.mdf', 
 @filename2 = 'c:\Dados\PEDIDOS_INDICES.ndf', 
 @filename3 = 'c:\Dados\PEDIDOS_log.ldf'

go

-- Laborat�rio 2
--1
USE PEDIDOS
GO

/*
2.	Crie uma consulta que apresente as vendas por Tipo de produto. 
Campos: Tipo de Produto,  Descricao,  Ano, M�s, Valor total.
Condi��o: Ano de 2014.
Ordena��o: Tipo de Produto , DESCRI��O, ANO E M�S
*/
SELECT		T.TIPO , 
			PR.DESCRICAO , 
			YEAR(PE.DATA_EMISSAO) AS ANO,
			MONTH(PE.DATA_EMISSAO) AS MES,
			SUM(I.PR_UNITARIO * I.QUANTIDADE * (1 - I.DESCONTO/100)) AS TOTAL
FROM		TB_PEDIDO AS PE
JOIN		TB_ITENSPEDIDO AS I ON I.NUM_PEDIDO = PE.NUM_PEDIDO 
JOIN		TB_PRODUTO AS PR ON	PR.ID_PRODUTO = I.ID_PRODUTO 
JOIN		TB_TIPOPRODUTO AS T ON T.COD_TIPO = PR.COD_TIPO 
WHERE		YEAR(PE.DATA_EMISSAO) = 2014
GROUP BY	T.TIPO , 
			PR.DESCRICAO , 
			YEAR(PE.DATA_EMISSAO) ,
			MONTH(PE.DATA_EMISSAO)
ORDER BY	T.TIPO 


/*3. Desenvolva uma consulta que apresente as vendas por estado com Ranking por Estado:

*Campos: Estado, Cidade, Ano, M�s e Valor total;
*Condi��o: Ano de 2014;
*Ordena��o: Ano, M�s, Estado e Cidade*/

SELECT Estado, Cidade, Ano, Mes , RANK() OVER (ORDER BY TOTAL DESC) AS RANKING
FROM 	
	(
	SELECT		C.ESTADO,
				C.CIDADE,
				YEAR(PE.DATA_EMISSAO) AS ANO,
				MONTH(PE.DATA_EMISSAO) AS MES,
				SUM(PE.VLR_TOTAL) AS TOTAL
	FROM		TB_PEDIDO AS PE
	JOIN		TB_CLIENTE AS C ON C.CODCLI = PE.CODCLI 
	WHERE		YEAR(PE.DATA_EMISSAO) = 2014
	GROUP BY	C.ESTADO,
				C.CIDADE,
				YEAR(PE.DATA_EMISSAO) ,
				MONTH(PE.DATA_EMISSAO)
	) AS A
ORDER BY	ANO, MES, ESTADO , CIDADE


/*4. Desenvolva uma consulta que apresente as vendas por vendedor, com Ranking por Vendedor:

	Campos: Nome do Vendedor, Ano, M�s, Valor Total e Comiss�o (VLR_TOTAL * PORC_COMISSAO /100);
	Condi��o: Ano de 2014;
	Ordena��o: Nome do Vendedor, Ano e M�s
*/
WITH CTE AS(
	SELECT		V.NOME ,
				YEAR(PE.DATA_EMISSAO) AS ANO,
				MONTH(PE.DATA_EMISSAO) AS MES,
				SUM(PE.VLR_TOTAL) AS TOTAL,
				SUM(VLR_TOTAL * PORC_COMISSAO /100) AS COMISSAO
	FROM		TB_PEDIDO AS PE
	JOIN		TB_VENDEDOR AS V ON V.CODVEN = PE.CODVEN 
	WHERE		YEAR(PE.DATA_EMISSAO) = 2014
	GROUP BY	V.NOME ,
				YEAR(PE.DATA_EMISSAO) ,
				MONTH(PE.DATA_EMISSAO)
	) 
SELECT	NOME ,ANO, MES, 
		RANK() OVER (ORDER BY TOTAL DESC) AS RANKING
FROM CTE
ORDER BY	NOME ,ANO, MES


-- Laborat�rio 3
/*1.	Crie uma VIEW que apresente as vendas por Vendedor.
Campos: Vendedor, Ano, M�s, Valor total e comiss�o.*/
GO
CREATE VIEW VW_COMISSAO_VENDEDOR AS
SELECT		V.NOME AS VENDEDOR,
			YEAR(PE.DATA_EMISSAO) AS ANO,
			MONTH(PE.DATA_EMISSAO) AS MES,
			SUM(PE.VLR_TOTAL) AS TOTAL,
			SUM(VLR_TOTAL * PORC_COMISSAO /100) AS COMISSAO
FROM		TB_PEDIDO AS PE
JOIN		TB_VENDEDOR AS V ON V.CODVEN = PE.CODVEN 
GROUP BY	V.NOME ,
			YEAR(PE.DATA_EMISSAO) ,
			MONTH(PE.DATA_EMISSAO)
GO			

--2.	Utilize a VIEW criada no exerc�cio anterior e mostre todas as vendas de 2014 ordenada pelo Nome do vendedor.
SELECT * FROM VW_COMISSAO_VENDEDOR WHERE ANO = 2014 ORDER BY VENDEDOR

--3.	Crie uma VIEW que mostre: N�mero do Pedido, data da emiss�o, nome do Cliente, nome do Vendedor, Valor total da venda.
GO
CREATE VIEW VW_NRO_PEDIDO AS 
SELECT		PE.NUM_PEDIDO AS PEDIDO,
			PE.DATA_EMISSAO ,
			C.NOME AS CLIENTE,
			V.NOME AS VENDEDOR,
			PE.VLR_TOTAL AS TOTAL
FROM		TB_PEDIDO AS PE
JOIN		TB_VENDEDOR AS V ON V.CODVEN = PE.CODVEN 
JOIN		TB_CLIENTE AS C ON C.CODCLI = PE.CODCLI 
GO
--4.	Realize uma consulta utilizando a VIEW criada no exerc�cio anterior mostrando as vendas de 2014 ordenado pelo nome do cliente e n�mero do pedido.
SELECT * FROM VW_NRO_PEDIDO 
WHERE YEAR(DATA_EMISSAO) = 2014
ORDER BY CLIENTE , PEDIDO

--5.	Crie um VIEW que apresente os campos: N�mero do Pedido, data de emiss�o, Tipo do Produto, Descri��o do Produto e a soma das quantidades vendidas.
GO
CREATE VIEW VW_PEDIDOS_PRODUTOS AS 
SELECT		PE.NUM_PEDIDO ,
			PE.DATA_EMISSAO,
			T.TIPO , 
			PR.DESCRICAO , 
			SUM(I.QUANTIDADE) AS QUANTIDADE
FROM		TB_PEDIDO AS PE
JOIN		TB_ITENSPEDIDO AS I ON I.NUM_PEDIDO = PE.NUM_PEDIDO 
JOIN		TB_PRODUTO AS PR ON	PR.ID_PRODUTO = I.ID_PRODUTO 
JOIN		TB_TIPOPRODUTO AS T ON T.COD_TIPO = PR.COD_TIPO 
GROUP BY	PE.NUM_PEDIDO ,
			PE.DATA_EMISSAO,
			T.TIPO , 
			PR.DESCRICAO 

GO

--6.	Execute a View do exerc�cio anterior mostrando todos os campos, filtrando pelo ano de 2014 e ordenando pelo tipo do produto.
SELECT * FROM VW_PEDIDOS_PRODUTOS WHERE YEAR(DATA_EMISSAO) = 2014 
ORDER BY TIPO

--Laborat�rio 4 � Procedures

/*1.	Crie uma PROCEDURE que apresente:
Campos: Nome do Vendedor, Ano, M�s, Valor total, 
        Comiss�o (VLR_TOTAL * PORC_COMISSAO /100)
Ordena��o: Nome do Vendedor, Ano, M�s.
Par�metro: Ano 

Observa��o: Deve ser apresentado somente os vendedores que venderam em todos os meses.*/
GO

CREATE PROCEDURE SP_VENDAS_VENDEDOR @ANO INT AS
BEGIN

	DECLARE @MES INT = 1

	CREATE TABLE #TMP (
	ANO			INT,
	MES			INT,
	CODVEN		INT,
	VENDEDOR	VARCHAR(50) ,
	TOTAL		DECIMAL(10,2),
	COMISSAO	DECIMAL(10,2) )
	
	CREATE TABLE #MES 
	(	ANO	INT,
		MES INT)


	WHILE @MES<=12
		BEGIN
			INSERT INTO #MES VALUES (@ANO , @MES)
			SET @MES += 1
		END
	
	INSERT INTO #TMP (ANO, MES , CODVEN, VENDEDOR)
	SELECT ANO, MES, CODVEN, NOME FROM #MES CROSS JOIN TB_VENDEDOR 
	
	UPDATE		#TMP SET 
	TOTAL =		(	SELECT	SUM(PE.VLR_TOTAL) 
					FROM	TB_PEDIDO AS PE 
					JOIN	TB_VENDEDOR AS V ON V.CODVEN = PE.CODVEN 
					WHERE	YEAR(PE.DATA_EMISSAO) = @ANO
					AND		MONTH(PE.DATA_EMISSAO) = #TMP.MES
					AND		V.CODVEN = #TMP.CODVEN) ,
	COMISSAO = (	SELECT	SUM(VLR_TOTAL * PORC_COMISSAO /100)
					FROM	TB_PEDIDO AS PE 
					JOIN	TB_VENDEDOR AS V ON V.CODVEN = PE.CODVEN 
					WHERE	YEAR(PE.DATA_EMISSAO) = @ANO
					AND		MONTH(PE.DATA_EMISSAO) = #TMP.MES
					AND		V.CODVEN = #TMP.CODVEN)
	
	SELECT * FROM #TMP WHERE CODVEN NOT IN (SELECT CODVEN FROM #TMP WHERE TOTAL IS NULL)
	
END

GO

---OU

CREATE  PROCEDURE SP_VENDAS_VENDEDOR @ANO INT AS
BEGIN

	WITH CTE AS
	(	SELECT COUNT(*) AS QTD, CODVEN 
		FROM 	
			(SELECT distinct MONTH(DATA_EMISSAO) AS MES , CODVEN
			FROM TB_PEDIDO
			WHERE YEAR(DATA_EMISSAO)= @ANO
			) AS A
		GROUP BY CODVEN
	) 
	SELECT V.NOME, @ANO AS ANO, MONTH(P.DATA_EMISSAO) AS MES,
	SUM(P.VLR_TOTAL) AS TOTAL,
	SUM(P.VLR_TOTAL*V.PORC_COMISSAO/100) AS COMISSAO
	FROM CTE
	JOIN TB_PEDIDO		AS P ON CTE.CODVEN = P.CODVEN 
	JOIN TB_VENDEDOR	AS V ON CTE.CODVEN= V.CODVEN 
	WHERE QTD=12 
	AND  YEAR(P.DATA_EMISSAO)= @ANO
	GROUP BY V.NOME, MONTH(P.DATA_EMISSAO) 
	ORDER BY 1,2,3
END

--2.	Execute a procedure filtrando pelo ano de 2014.
EXEC SP_VENDAS_VENDEDOR 2014 

/*3.	Crie tabela tb_ResumoVenda, com as caracter�sticas abaixo:
ID		INT	Auto numer�vel e Primary KEY
Ano		INT
M�S		INT
Valor_Total	DECIMAL(10,2)
*/
GO
CREATE TABLE tb_ResumoVenda (
ID		INT		IDENTITY  Primary KEY,
Ano		INT,
MES		INT,
Valor_Total	DECIMAL(10,2) )

GO

/* 4.	Crie uma PROCEDURE que fa�a uma carga na tabela tb_ResumoVenda com as caracter�sticas:
Par�metros: Ano e M�s
Resumo: Realizar consulta da tabela pedidos e gravar na tabela tb_ResumoVenda.
Tratamento de erros: Utilizar tratamento de erros TRY e CATCH
Transa��o: Utilizar BEGIN TRAN
Observa��o: Apague os registros correspondentes ao m�s e ano da tabela caso exista.*/

CREATE  PROCEDURE SP_CARGA_tb_ResumoVenda  @ANO INT , @MES INT AS
BEGIN
SET NOCOUNT ON
	BEGIN TRY
	BEGIN TRAN
	
	DELETE FROM Tb_ResumoVenda 
	WHERE ANO = @ANO AND MES = @MES

	INSERT INTO Tb_ResumoVenda (ANO , MES , VALOR_TOTAL) 
	SELECT YEAR(PE.DATA_EMISSAO) , MONTH(PE.DATA_EMISSAO) , SUM(PE.VLR_TOTAL)
	FROM TB_PEDIDO AS PE
	WHERE YEAR(PE.DATA_EMISSAO) = @ANO AND MONTH(PE.DATA_EMISSAO) = @MES
	GROUP BY YEAR(PE.DATA_EMISSAO) , MONTH(PE.DATA_EMISSAO)
	COMMIT
		PRINT 'CARGA REALIZADA COM SUCESSO'
	END TRY
	BEGIN CATCH
		ROLLBACK
		PRINT 'ERRO: ' + ERROR_MESSAGE()
	END CATCH
END

GO

--Teste
exec SP_CARGA_tb_ResumoVenda 2014,2

SELECT * FROM Tb_ResumoVenda

--Laborat�rio 5 � Fun��es
--1.	Crie uma Fun��o que retorne o primeiro e o �ltimo nome passado como par�metro.
GO
CREATE FUNCTION FN_PRIM_ULT_NOME( @S VARCHAR(200) )
   RETURNS VARCHAR(200)
AS BEGIN
	DECLARE @RET VARCHAR(200) ='', @CONT INT = 1, @FINAL_P INT = 0, @INICIO_S INT = 0

	SET @S = LTRIM(RTRIM( @S ));

	WHILE @CONT <=LEN(@S)
	   BEGIN
		 IF SUBSTRING(@S, @CONT, 1) = ' '  
			IF @FINAL_P = 0 
			   SET @FINAL_P = @CONT
		    ELSE
			   SET @INICIO_S = @CONT
	
		 SET @CONT += 1;
	   END

	-- Localizou mais de 2 espa�os
	IF @FINAL_P <> 0 AND  @INICIO_S <> 0
	   SET @RET = SUBSTRING(@S, 1 ,@FINAL_P) + ' ' + SUBSTRING(@S, @INICIO_S ,@CONT - @INICIO_S);

	-- N�o localizou espa�o
	IF @FINAL_P = 0
	   SET @RET = @S 
	 
	-- Localizou 1 espa�o   	
	IF @FINAL_P <> 0 AND  @INICIO_S = 0
	   SET @RET = SUBSTRING(@S, 1 ,@FINAL_P) + ' ' + SUBSTRING(@S, @FINAL_P  , @CONT - @FINAL_P);

	RETURN  @RET ;
END

GO
-- Teste

SELECT DBO.FN_PRIM_ULT_NOME('DANIEL PAULO SALVADOR')
SELECT DBO.FN_PRIM_ULT_NOME(' DANIEL PAULO SALVADOR ')
SELECT DBO.FN_PRIM_ULT_NOME('DANIEL SALVADOR')
SELECT DBO.FN_PRIM_ULT_NOME('DANIELPAULOSALVADOR')
SELECT DBO.FN_PRIM_ULT_NOME(' DANIELPAULOSALVADOR ')


--2.	Crie uma fun��o que retorne o Nome do Cliente, ano, m�s, �ltimo valor de compra. Utilize o par�metro Ano para filtrar a consulta.
GO

CREATE FUNCTION FN_RETORNA_ULTIMA_COMPRA (@ANO INT )
RETURNS TABLE
RETURN (

WITH PEDIDO_CTE (CODCLI , NOME , PEDIDO) AS
(
	SELECT  P.CODCLI ,C.NOME ,   MAX(NUM_PEDIDO) 
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	WHERE YEAR(DATA_EMISSAO) = @ANO
	GROUP BY P.CODCLI, C.NOME 
)

SELECT C.CODCLI, C.NOME AS CLIENTE, C.PEDIDO , PE.VLR_TOTAL , @ANO AS ANO, MONTH(PE.DATA_EMISSAO) AS MES
FROM PEDIDO_CTE AS C
JOIN TB_PEDIDO AS PE ON PE.NUM_PEDIDO = C.PEDIDO 
 )

 GO

 --TESTE

 SELECT * FROM DBO.FN_RETORNA_ULTIMA_COMPRA(2014) ORDER BY ANO, MES




