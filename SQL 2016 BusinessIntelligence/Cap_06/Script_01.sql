USE MASTER
go

IF EXISTS (SELECT * FROM MASTER..SYSDATABASES WHERE NAME ='dw_Custo')
	DROP DATABASE dw_Custo
go
create database dw_Custo collate SQL_Latin1_General_CP1_CI_AS
go

USE dw_Custo 
go

create table dim_Filial (
id_Filial	int identity primary key,
Filial		varchar(50)
)
go
insert into dim_Filial values
('São Paulo'),
('Rio de Janeiro'),
('Belo Horizonte'),
('Manaus')
go

CREATE TABLE DIM_PERIODO (
ID_PERIODO	INT 	IDENTITY  PRIMARY KEY,
ANO			INT,
MÊS			INT,
DIA			INT)
GO


declare @dia datetime = '2014.1.1'

while @dia<='2014.12.31'
	begin
		insert into DIM_PERIODO values
		(year(@dia), month(@dia) , day(@dia))

		set @dia +=1
	end

go
CREATE TABLE DIM_CENTROCUSTO (
id_CC	int			identity	primary key,
CC		varchar(50) 		
)
go

insert into DIM_CENTROCUSTO values
('Administração'),
('Matéria Prima'),
('Folha de Pagamento') ,
('Terceiros'),
('Impostos'),
('Manutenção')
go

CREATE TABLE DIM_PRODUTO (
ID_PRODUTO		INT 	IDENTITY PRIMARY KEY,
PRODUTO			VARCHAR(40),
TIPO			VARCHAR(40),
UNIDADE			VARCHAR(40))
GO


INSERT INTO DIM_PRODUTO (PRODUTO ,TIPO,UNIDADE) 
SELECT DISTINCT PR.DESCRICAO , T.TIPO , U.UNIDADE 
FROM PEDIDOS..TB_PRODUTO		AS PR
JOIN PEDIDOS..TB_TIPOPRODUTO	AS T ON T.COD_TIPO = PR.COD_TIPO 
JOIN PEDIDOS..TB_UNIDADE		AS U ON U.COD_UNIDADE = PR.COD_UNIDADE 
JOIN PEDIDOS..TB_ITENSPEDIDO	AS I ON I.ID_PRODUTO = PR.ID_PRODUTO 
JOIN PEDIDOS..TB_PEDIDO		AS P ON P.NUM_PEDIDO = I.NUM_PEDIDO 
WHERE 
YEAR(P.DATA_EMISSAO) = 2014
go

create table tb_fato_Custo (
id				int	identity	primary key,
id_periodo		int,
id_Filial		int,
id_CC			int,
Valor			decimal(10,2))

go

alter table tb_fato_Custo add
CONSTRAINT FK_FATO_CUSTO_PERIODO		FOREIGN KEY (ID_PERIODO) REFERENCES DIM_PERIODO (ID_PERIODO),
CONSTRAINT FK_FATO_CUSTO_FILIAL			FOREIGN KEY (ID_FILIAL) REFERENCES DIM_FILIAL (ID_FILIAL),
CONSTRAINT FK_FATO_CUSTO_CENTROCUSTO	FOREIGN KEY (id_CC) references DIM_CENTROCUSTO(id_cc)

go


declare @id_periodo int , @Filial int , @CC int

declare Cr_Cursor cursor keyset for 
select id_periodo from DIM_PERIODO

open Cr_Cursor

fetch first from Cr_Cursor into @id_periodo
while @@FETCH_STATUS = 0
begin
	declare Cr_Filial cursor keyset for select id_filial from DIM_Filial
	open Cr_Filial
	fetch first from Cr_Filial into @Filial
	while @@FETCH_STATUS = 0
		begin
			declare Cr_CC cursor keyset for select id_cc from DIM_CENTROCUSTO
			open Cr_CC
			fetch first from Cr_CC into @CC
			while @@FETCH_STATUS = 0
				begin
					insert into tb_fato_Custo (id_periodo,id_Filial,id_CC,Valor) values 
					(@id_periodo ,@Filial, @CC , rand() * 1000)
					fetch next from Cr_CC into @CC
				end
				close Cr_CC
				deallocate Cr_CC
	
			fetch next from Cr_Filial into @Filial
		end
		close Cr_Filial
		deallocate Cr_Filial
	fetch next from Cr_Cursor into @id_periodo
end
close Cr_Cursor
deallocate Cr_Cursor

go

