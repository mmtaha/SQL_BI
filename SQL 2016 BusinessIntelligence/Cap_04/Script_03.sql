--Consulta para retornar Estado e Cidade
SELECT DISTINCT ESTADO, CIDADE FROM TB_CLIENTE WHERE ESTADO IS NOT NULL;

-- Consulta para retornar Ano, m?s e dia
SELECT DISTINCT YEAR(DATA_EMISSAO) AS ANO , 
MONTH(DATA_EMISSAO) AS MES, DAY(DATA_EMISSAO) AS DIA
FROM TB_PEDIDO;


--Consulta para retornar Produtos
SELECT P.DESCRICAO, T.TIPO , U.UNIDADE
FROM	TB_PRODUTO AS P
JOIN	TB_TIPOPRODUTO AS T ON T.COD_TIPO = P.COD_TIPO
JOIN	TB_UNIDADE AS U ON U.COD_UNIDADE = P.COD_UNIDADE
