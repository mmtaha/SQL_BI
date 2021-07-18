EXEC sp_attach_db 
 @dbname    = 'PEDIDOS',   
 @filename1 = 'c:\BcoDadosPedidos_2016\PEDIDOS_TABELAS.mdf', 
 @filename2 = 'c:\BcoDadosPedidos_2016\PEDIDOS_INDICES.ndf', 
 @filename3 = 'c:\BcoDadosPedidos_2016\PEDIDOS_log.ldf'

