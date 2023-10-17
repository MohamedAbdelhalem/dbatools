exec [master].[dbo].[sp_big_table_summarizing]
@table_name		= '[PRODmfreportsdbBAB].[dbo].[middleware_requests]', 
@summary_table		= '[master].[dbo].[middleware_requests_summary2]',
@bulk			= 1000, --max value 3,000 rows
@cluster_index_key	= '[id]',
@stop_date_column	= '[ts]',
@keep_months		= 13

