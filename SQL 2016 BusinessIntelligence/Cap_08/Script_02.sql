SELECT * FROM TB_CLIENTE ORDER BY NOME;

SELECT * FROM TB_FORNECEDOR ORDER BY NOME;

select year(data_emissao) as ano, month(data_emissao) as mes , sum(vlr_total) as total
from tb_pedido where  year(data_emissao) = @ano
group by year(data_emissao) , month(data_emissao);






