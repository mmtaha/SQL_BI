
select year(data_emissao) as ano, month(data_emissao) as mes , sum(vlr_total) as total
from tb_pedido where  year(data_emissao) = @ano
group by year(data_emissao) , month(data_emissao);

select month(data_emissao) as mes , sum(vlr_total) as total
from tb_pedido where  year(data_emissao) = @ano
group by year(data_emissao) , month(data_emissao);

select month(data_emissao) as mes , Num_pedido, data_emissao, vlr_total as total
from tb_pedido 
where  year(data_emissao) = @ano


Select * from tb_cliente where codcli=@codcli


SELECT 
TOTAL,META,
	CASE 
	WHEN TOTAL/META < .5 THEN -1
	WHEN TOTAL/META < .7 THEN 0
	ELSE 1
	END AS STATUS	
FROM 
	(SELECT 
	SUM(VLR_TOTAL) AS TOTAL,
	500000 AS META
	FROM PEDIDOS.DBO.TB_PEDIDO
	WHERE YEAR(DATA_EMISSAO)=2014
	AND MONTH(DATA_EMISSAO) = 10
	) AS A


SELECT 
	SUM(VLR_TOTAL) AS TOTAL,
	MONTH(VLR_TOTAL) AS MES
	FROM PEDIDOS.DBO.TB_PEDIDO
	WHERE YEAR(DATA_EMISSAO)=2014
	AND MONTH(VLR_TOTAL) IS NOT NULL
	GROUP BY MONTH(VLR_TOTAL)
	ORDER BY MES

