exec master.[dbo].[sp_big_table_bulk_delete]
@table_name		= '[PRODmfreportsdbBAB].[dbo].[middleware_requests]', 
@cluster_index_key	= '[id]',
@stop_date_column	= '[ts]'