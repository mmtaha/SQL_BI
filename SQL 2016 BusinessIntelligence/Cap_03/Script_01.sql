--Laborat�rio 1 - Preparando o ambiente de pastas

--5.	Crie um banco de nome DW_IMPACTA;

CREATE DATABASE DW_IMPACTA collate SQL_Latin1_General_CP1_CI_AS
GO

--Laborat�rio 2 � Criando a estrutura do DW

--1.	Coloque o banco de dados DW_IMPACTA em uso;

USE DW_IMPACTA
GO

--2.	Criar as tabelas de dimens�es e fato conforme modelo:
/*Tabela dim_Regiao
Id_Regiao	int 	auto numer�vel primary key
Sigla		char(2)
Estado		varchar(20)
Cidade	varchar(40)*/

CREATE TABLE DIM_REGIAO (
ID_REGIAO	INT 	IDENTITY  PRIMARY KEY,
SIGLA		CHAR(2),
ESTADO		VARCHAR(20),
CIDADE		VARCHAR(40))

GO

/*Tabela dim_Periodo
Id_Periodo	int 	auto numer�vel primary key
Ano		int
Mes		int
Dia		int*/
CREATE TABLE DIM_PERIODO (
ID_PERIODO	INT 	IDENTITY  PRIMARY KEY,
ANO			INT,
MES			INT,
DIA			INT)
GO
/*Tabela dim_Produto
Id_Produto	int 	auto numer�vel primary key
Produto	varchar(40)
Tipo		varchar(40)
Unidade	varchar(40)*/

CREATE TABLE DIM_PRODUTO (
ID_PRODUTO		INT 	IDENTITY PRIMARY KEY,
PRODUTO			VARCHAR(40),
TIPO			VARCHAR(40),
UNIDADE			VARCHAR(40))
GO

/*Tabela fato_venda
Id_periodo	int	
Id_Regiao	int
Id_produto	int
Quantidade	int
Pedidos	int
Valor		decimal(10,2)

Criar as CONSTRAINTS:
PRIMARY KEY com os campos (id_periodo , id_regiao, id_produto)
FOREIGN KEY: id_periodo , id_regiao, id_produto*/


CREATE TABLE FATO_VENDA (
ID_PERIODO	INT	,
ID_REGIAO	INT,
ID_PRODUTO	INT,
QUANTIDADE	INT,
PEDIDOS		INT,
VALOR		DECIMAL(10,2) ,
CONSTRAINT PK_FATO_VENDA PRIMARY KEY (ID_PERIODO , ID_REGIAO, ID_PRODUTO) ,
CONSTRAINT FK_FATO_VENDA_PERIODO FOREIGN KEY (ID_PERIODO) REFERENCES DIM_PERIODO (ID_PERIODO),
CONSTRAINT FK_FATO_VENDA_REGIAO FOREIGN KEY (ID_REGIAO) REFERENCES DIM_REGIAO (ID_REGIAO),
CONSTRAINT FK_FATO_VENDA_PRODUTO FOREIGN KEY (ID_PRODUTO) REFERENCES DIM_PRODUTO (ID_PRODUTO))

GO

--Laborat�rio 3 � Cria��o das procedures de carga


/*1.	Criar uma procedure para carga da tabela dim_Regiao.
Nome: SP_Carrega_dim_regiao
Par�metros: Ano INT e M�s INT
Descri��o: Fazer uma consulta nas tabelas de Pedidos e clientes do banco Pedidos e inserir na tabela dim_regiao.
Observa��o: N�o inserir registros j� existente na tabela dim_Regiao.*/

CREATE PROCEDURE SP_CARREGA_DIM_REGIAO @ANO INT , @MES INT AS
BEGIN

	INSERT INTO DIM_REGIAO (SIGLA,ESTADO,CIDADE) 
	SELECT DISTINCT ESTADO, ESTADO, CIDADE 
	FROM PEDIDOS..TB_PEDIDO AS P
	JOIN PEDIDOS..TB_CLIENTE AS C ON P.CODCLI = C.CODCLI 
	WHERE 
	YEAR(DATA_EMISSAO) = @ANO AND 
	MONTH(DATA_EMISSAO) = @MES
	EXCEPT
	SELECT SIGLA,ESTADO,CIDADE FROM DIM_REGIAO

END
GO
-- Teste
exec SP_CARREGA_DIM_REGIAO 2014,3

-- 
SELECT * FROM DIM_REGIAO

/*2.	Criar uma procedure para carga da tabela dim_Periodo.
Nome: SP_Carrega_dim_Periodo
Par�metros: Ano INT e M�s INT
Descri��o: Fazer uma consulta na tabela de Pedidos do banco Pedidos agrupando por Ano, m�s e dia e inserir na tabela dim_Periodo.
Observa��o: N�o inserir registros j� existentes na tabela dim_Periodo*/
GO
CREATE PROCEDURE  SP_CARREGA_DIM_PERIODO @ANO INT , @MES INT AS
BEGIN

	INSERT INTO DIM_PERIODO (ANO, MES, DIA) 
	SELECT @ANO , @MES , DAY(DATA_EMISSAO) 
	FROM PEDIDOS..TB_PEDIDO
	WHERE 
	YEAR(DATA_EMISSAO) = @ANO AND 
	MONTH(DATA_EMISSAO) = @MES
	EXCEPT
	SELECT ANO , MES , DIA FROM DIM_PERIODO

END

GO
-- TESTE 
EXEC SP_CARREGA_DIM_PERIODO 2014,1

--
SELECT * FROM DIM_PERIODO

/*3.	Criar uma procedure para carga da tabela dim_Produto.
Nome: SP_Carrega_dim_Produto
Par�metros: Ano INT e M�s INT
Descri��o: Fazer uma consulta na tabela de Pedidos do banco Pedidos agrupando por Produto, Ano, m�s e dia e inserir na tabela dim_Produto.
Observa��o: N�o inserir registros j� existentes na tabela dim_Produto*/
go

CREATE PROCEDURE SP_CARREGA_DIM_PRODUTO @ANO INT , @MES INT AS
BEGIN
	
	INSERT INTO DIM_PRODUTO (PRODUTO ,TIPO,UNIDADE) 
	SELECT DISTINCT PR.DESCRICAO , T.TIPO , U.UNIDADE 
	FROM PEDIDOS..TB_PRODUTO		AS PR
	JOIN PEDIDOS..TB_TIPOPRODUTO	AS T ON T.COD_TIPO = PR.COD_TIPO 
	JOIN PEDIDOS..TB_UNIDADE		AS U ON U.COD_UNIDADE = PR.COD_UNIDADE 
	JOIN PEDIDOS..TB_ITENSPEDIDO	AS I ON I.ID_PRODUTO = PR.ID_PRODUTO 
	JOIN PEDIDOS..TB_PEDIDO		AS P ON P.NUM_PEDIDO = I.NUM_PEDIDO 
	WHERE 
	YEAR(P.DATA_EMISSAO) = @ANO AND 
	MONTH(P.DATA_EMISSAO) = @MES
	EXCEPT 
	SELECT PRODUTO ,TIPO,UNIDADE FROM DIM_PRODUTO
	
END 
GO

--TESTE
EXEC SP_CARREGA_DIM_PRODUTO 2014,3

--
SELECT * FROM DIM_PRODUTO


/*4.	Criar uma procedure para apagar um per�odo de informa��es:
Nome: SP_Apaga_Carga
Par�metros: Ano INT e M�s INT
Descri��o: Apagar os dados da tabela fato_venda do per�odo passado pelos par�metros.*/

GO

CREATE PROCEDURE SP_APAGA_CARGA @ANO INT, @MES INT AS
BEGIN

	DELETE FROM FATO_VENDA 
	FROM FATO_VENDA AS F
	JOIN DIM_PERIODO AS DP ON DP.ID_PERIODO = F.ID_PERIODO 
	WHERE DP.ANO =@ANO AND DP.MES= @MES

END
GO

--TESTE
EXEC SP_APAGA_CARGA 2014,1

--
SELECT * FROM FATO_VENDA



/*5.	Criar uma procedure para carga da tabela fato_venda.
Nome: SP_Carrega_fato_venda
Par�metros: Ano INT e M�s INT
Descri��o: Fazer uma consulta relacionando as dimens�es com a tabela Pedidos e Itenspedidos. 
Para calcular o valor utilize a formula: sum(i.QUANTIDADE * i.PR_UNITARIO * (1-desconto/100))
Agrupe a informa��o e insira na fato_venda. 
Observa��o: N�o inserir registros j� existentes na tabela fato_venda.
*/
GO 
CREATE PROCEDURE SP_CARREGA_FATO_VENDA @ANO INT, @MES INT AS
BEGIN

	IF NOT EXISTS (	SELECT * 
				FROM FATO_VENDA AS F 
				JOIN DIM_PERIODO AS P ON F.ID_PERIODO = P.ID_PERIODO 
				WHERE P.ANO = @ANO AND P.MES= @MES)

		INSERT INTO FATO_VENDA (ID_PERIODO, ID_REGIAO, ID_PRODUTO, QUANTIDADE, PEDIDOS, VALOR)
		SELECT	DP.ID_PERIODO , DR.ID_REGIAO , DPR.ID_PRODUTO , SUM(I.QUANTIDADE) ,
		COUNT(*) , SUM(I.QUANTIDADE * I.PR_UNITARIO * (1-DESCONTO/100)) 

		FROM	PEDIDOS..TB_PEDIDO		AS P
		JOIN	PEDIDOS..TB_ITENSPEDIDO	AS I	ON I.NUM_PEDIDO = P.NUM_PEDIDO 
		JOIN	PEDIDOS..TB_PRODUTO		AS PR	ON PR.ID_PRODUTO = I.ID_PRODUTO 
		JOIN	PEDIDOS..TB_TIPOPRODUTO	AS T	ON T.COD_TIPO = PR.COD_TIPO 	
		JOIN	PEDIDOS..TB_UNIDADE		AS U	ON U.COD_UNIDADE =PR.COD_UNIDADE 
		JOIN	PEDIDOS..TB_CLIENTE		AS C	ON C.CODCLI =P.CODCLI 
		JOIN	DIM_PERIODO				AS DP	ON	DP.ANO = YEAR(P.DATA_EMISSAO)  AND 
													DP.MES=MONTH(P.DATA_EMISSAO)  AND
													DP.DIA=DAY(P.DATA_EMISSAO) 
		JOIN	DIM_REGIAO				AS DR	ON	DR.SIGLA  = C.ESTADO AND
													DR.CIDADE = C.CIDADE 
		JOIN	DIM_PRODUTO				AS DPR	ON	DPR.PRODUTO =PR.DESCRICAO AND
													DPR.TIPO = T.TIPO AND
													DPR.UNIDADE =U.UNIDADE 
		WHERE 
		YEAR(P.DATA_EMISSAO) = @ANO AND
		MONTH(P.DATA_EMISSAO) = @MES
		GROUP BY DP.ID_PERIODO , DR.ID_REGIAO , DPR.ID_PRODUTO

END
GO
--TESTE

EXEC SP_CARREGA_FATO_VENDA 2014,1
--
SELECT * FROM FATO_VENDA
