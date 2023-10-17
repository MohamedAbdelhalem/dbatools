use master
go
exec [PRODmfreportsdbBAB].[dbo].sp_table_size '','middleware_requests'
go
exec master.[dbo].[sp_big_table_bulk_delete]
@table_name				= '[PRODmfreportsdbBAB].[dbo].[middleware_requests]', 
@cluster_index_key		= '[id]',
@stop_date_column		= '[ts]'
go
exec [PRODmfreportsdbBAB].[dbo].sp_table_size '','middleware_requests'


--middleware_requests	[dbo].[middleware_requests]	1,850,870,238	FILEGROUP	PRIMARY	1.17 TB	1.17 TB	2.98 GB	1.16 TB	9.67 GB	1255681240
--middleware_requests	[dbo].[middleware_requests]	1,850,469,238	FILEGROUP	PRIMARY	1.17 TB	1.17 TB	2.98 GB	1.16 TB	9.63 GB	1255365080

--msdb.dbo.sp_start_job 'PRODmfreportsdbBAB - Purge Monthly'
