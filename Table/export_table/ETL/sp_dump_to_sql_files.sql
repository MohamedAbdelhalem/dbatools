use master
go
if object_id('[dbo].[sp_dump_to_sql_files]') is not null
begin
drop procedure [dbo].[sp_dump_to_sql_files]
end
go

CREATE Procedure [dbo].[sp_dump_to_sql_files]
(
@database_name		varchar(500) /*='T24SDC61'*/,
@table_name			varchar(500) /*= 'dbo.[F_BAB_L_GEN_ACCT_STMT]'*/,
@new_table_name		varchar(500) /*= 'dbo.[F_BAB_L_GEN_ACCT_STMT]'*/,
@summary_table_name varchar(500) /*= FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_cumulative_summary5*/,
@columns			varchar(3000) /*= 'RECID, XMLRECORD'*/,
@unique_column_pk	varchar(150) /*= 'RECID'*/,
@queryout_file		varchar(3000) /*= 'K:\Export\'*/,
@server_name		varchar(50) /*= '10.37.3.61,17120'*/,
@bulk				int /*= 1000*/,
@from_file_id		int,
@to_file_id			int)
as
begin
set nocount on
declare 
@from_unique_column varchar(300), @to_unique_column varchar(300), 
@from_id bigint, @to_id bigint, 
@bcp_sql varchar(4000), 
@cur_sql varchar(2000)


declare @summary_table TABLE (
[id] [bigint] NULL,
[unique_id] [bigint] NULL,
[from_id] [bigint] NULL,
[to_id] [bigint] NULL,
[from_unique_column] [varchar](500) NULL,
[to_unique_column] [varchar](500) NULL)

set @cur_sql = 'select from_id, to_id, from_unique_column, to_unique_column 
from (
select row_number() over(order by from_id) id, from_id, to_id, from_unique_column, to_unique_column 
from master.dbo.['+@summary_table_name+']
where from_id != to_id)a
where id between '+cast(@from_file_id as varchar(100))+' and '+cast(@to_file_id as varchar(100))+'
order by id '

insert into @summary_table
exec(@cur_sql)

declare exp_cur cursor fast_forward
for
select from_id, to_id, from_unique_column, to_unique_column 
from @summary_table
order by id 

set @queryout_file = case when right(ltrim(rtrim(@queryout_file)),1) = '\' then ltrim(rtrim(@queryout_file)) + replace(replace(replace(@table_name,']',''),'[',''),'.','_') else ltrim(rtrim(@queryout_file))+ '\' + replace(replace(replace(@table_name,']',''),'[',''),'.','_') end

open exp_cur
fetch next from exp_cur into @from_id, @to_id, @from_unique_column, @to_unique_column
while @@FETCH_STATUS = 0
begin

--select @database_name, @table_name, @new_table_name, @columns , @unique_column_pk, @from_unique_column, @to_unique_column, @unique_column_pk, cast(@bulk as varchar(10)), @queryout_file, @from_id , @to_id , @server_name, replace(replace(@database_name,']',''),'[','')
set @bcp_sql = 'bcp "exec '+@database_name+'.[dbo].[sp_dump_table] @table = '+''''+@table_name+''''+', @new_name = '+''''+@new_table_name+''''+', @columns = '+''''+ @columns +''''+', @where_records_condition = ''where ['+@unique_column_pk+'] between '+''''+''''+@from_unique_column+''''+''''+' and '+''''+''''+@to_unique_column+''''+''''+' order by ['+@unique_column_pk+']'',@with_computed = 0, @header = 0, @bulk = '+cast(@bulk as varchar(10))+'" queryout "'+@queryout_file+'_from_'+cast(@from_id as varchar(50))+'_to_'+cast(@to_id as varchar(50))+'.sql" -S '+@server_name+' -d '+replace(replace(@database_name,']',''),'[','')+' -T -n -c > nul'
--print @bcp_sql
exec xp_cmdshell @bcp_sql

fetch next from exp_cur into @from_id, @to_id, @from_unique_column, @to_unique_column
end
close exp_cur
deallocate exp_cur
set nocount off
end

go

--select from_id, to_id, from_unique_column, to_unique_column 
--from (
--select row_number() over(order by from_id) id, from_id, to_id, from_unique_column, to_unique_column 
--from master.dbo.[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_summary5]
--where from_id != to_id)a
--order by id 

exec [dbo].[sp_dump_to_sql_files]
@database_name		= 'import_table',
@table_name			= 'dbo.[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_cumulative]',
@new_table_name		= 'dbo.[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019]',
@columns			= 'RECID, XMLRECORD',
@unique_column_pk	= 'RECID',
@queryout_file		= 'T:\Export\cumulative\',
@server_name		= '10.37.3.10',
@bulk				= 2000,
@from_file_id		= 1,
@to_file_id			= 5

