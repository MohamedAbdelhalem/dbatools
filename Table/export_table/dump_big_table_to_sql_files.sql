use master
go
if object_id('[dbo].[dump_big_table_to_sql_files]') is not null
begin
drop procedure [dbo].[dump_big_table_to_sql_files]
end
go
alter Procedure [dbo].[dump_big_table_to_sql_files](
@database_name		varchar(500)	= 'T24SDC61',
@table_name			varchar(500)	= 'dbo.[F_BAB_L_GEN_ACCT_STMT]',
@new_table_name		varchar(500)	= 'dbo.[F_BAB_L_GEN_ACCT_STMT]',
@columns			varchar(3000)	= 'RECID, XMLRECORD',
@unique_column_pk	varchar(150)	= 'RECID',
@queryout_file		varchar(3000)	= 'N:\Export\',
@server_name		varchar(50)		= '10.37.3.61,17120',
@bulk				int				= 150)
as
begin
set nocount on
declare 
@bcp_sql	 varchar(4000), 
@id			 int,
@min_RECID	 varchar(255),
@max_RECID	 varchar(255),
@xp_cmdshell varchar(1000) = 'xp_cmdshell ''dir cd "'+@queryout_file+'"'+'''',
@continue_after     int

declare @table table (output_text varchar(2500))
insert into @table
exec (@xp_cmdshell)

CREATE Table #null_output (output_temp varchar(20))

select @continue_after = max(id)
from (
select 
output_text dump_file_name, 
cast(substring(reverse(substring(reverse(output_text),1,charindex('_',reverse(output_text))-1)), 1, charindex('.',reverse(substring(reverse(output_text),1,charindex('_',reverse(output_text))-1)))-1) as int) id
from (
select substring(output_text, charindex(' ',output_text)+1, len(output_text)) output_text
from (
select ltrim(rtrim(substring(output_text, charindex('M ', output_text)+1, len(output_text)))) output_text
from @table
where output_text like '%M %'
and output_text not like '%<DIR>%')a)b)c

declare exp_cur cursor fast_forward
for
select id, min_RECID, max_RECID
from master.dbo.[F_BAB_L_REPORTS_LINES_summary]
where id > @continue_after
order by id 

set @queryout_file = case when right(ltrim(rtrim(@queryout_file)),1) = '\' then ltrim(rtrim(@queryout_file)) + replace(replace(replace(@table_name,']',''),'[',''),'.','_') else ltrim(rtrim(@queryout_file))+ '\' + replace(replace(replace(@table_name,']',''),'[',''),'.','_') end

open exp_cur
fetch next from exp_cur into @id, @min_RECID, @max_RECID
while @@FETCH_STATUS = 0
begin

set @bcp_sql = 'xp_cmdshell ''bcp "exec '+@database_name+'.[dbo].[sp_dump_table] @table = '+''''+''''+@table_name+''''+''''+', @new_name = '+''''+''''+@new_table_name+''''+''''+', @columns = '+''''+''''+@columns+''''+''''+', @where_records_condition = ''''where ['+@unique_column_pk+'] between '+''''+''''+''''+''''+@min_RECID+''''+''''+''''+''''+' and '+''''+''''+''''+''''+@max_RECID+''''+''''+''''+''''+' order by ['+@unique_column_pk+']'''',@with_computed = 0, @header = 0, @bulk = '+cast(@bulk as varchar(10))+'" queryout "'+@queryout_file+'_'+cast(@id as varchar(50))+'.sql" -S '+@server_name+' -d '+replace(replace(@database_name,']',''),'[','')+' -T -n -c > nul '''
--print @bcp_sql
insert into #null_output
exec (@bcp_sql)
--exec xp_cmdshell @bcp_sql

fetch next from exp_cur into @id, @min_RECID, @max_RECID
end
close exp_cur
deallocate exp_cur
set nocount off
end

go
