declare @table_name varchar(550) = '[dbo].[F_BAB_L_REPORTS_LINES]', @drop_and_create_new int = 1

declare @sql varchar(max), @summary_table_name varchar(550)
set @summary_table_name = case when charindex('.',replace(replace(@table_name,']',''),'[','')) > 0 
then '['+master.dbo.virtical_array(replace(replace(@table_name,']',''),'[',''),'.',1)+'].['+master.dbo.virtical_array(replace(replace(@table_name,']',''),'[',''),'.',2)+'_summary]'
else '[dbo].['+master.dbo.virtical_array(replace(replace(@table_name,']',''),'[',''),'.',2)+'_summary]' 
end

if object_id(@summary_table_name) is null
begin
	set @sql = 'CREATE Table [master].'+@summary_table_name+' (id int identity(1,1) primary key, min_RECID varchar(255), max_RECID varchar(255))'
	exec(@sql)
end
else
begin
	if @drop_and_create_new = 1
	begin
		set @sql = 'Drop Table [master].'+@summary_table_name
		exec(@sql)
		set @sql = 'CREATE Table [master].'+@summary_table_name+' (id int identity(1,1) primary key, min_RECID varchar(255), max_RECID varchar(255))'
		exec(@sql)
	end
end

go

declare @table_name varchar(550) = '[T24_support].[dbo].[F_BAB_L_REPORTS_LINES]', @drop_and_create_new int = 1

exec [dbo].[prepare_data_summary]
@db_sch_table			= @table_name,
@clustered_index_key	= '[RECID]',
@columns				= '[RECID],[XMLRECORD]',
@bulk					= 10005
go

select master.dbo.format(count(*) * 10000, -1) from [master].[dbo].[F_BAB_L_REPORTS_LINES_summary]

go

exec [dbo].[dump_big_table_to_sql_files]
@database_name		= '[T24_support]',
@table_name			= 'dbo.[F_BAB_L_REPORTS_LINES]',
@new_table_name		= 'dbo.[F_BAB_L_REPORTS_LINES]',
@columns			= 'RECID, XMLRECORD',
@unique_column_pk	= 'RECID',
@queryout_file		= 'E:\Export_F_BAB_L_REPORTS_LINES\',
@server_name		= '10.5.2.14',
@bulk				= 10005
