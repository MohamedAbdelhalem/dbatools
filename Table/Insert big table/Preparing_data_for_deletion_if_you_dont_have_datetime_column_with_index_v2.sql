use [master]
go
if object_id('dbo.prepare_data_summary') is not null
begin
drop procedure [dbo].[prepare_data_summary]
end
go
CREATE Procedure [dbo].[prepare_data_summary](
@db_sch_table			nvarchar(500) = '[T24SDC61].[dbo].[F_BAB_L_GEN_ACCT_STMT]',
@clustered_index_key	nvarchar(255) = '[RECID]',
@columns				nvarchar(500) = '[RECID],[XMLRECORD],[PROCESSING_DATE],[AUTH_DATE]',
@bulk					int = 100)
as
begin
declare
@min_ID					varchar(255), 
@max_ID					varchar(255),-- = (select max(max_RECID) from master.dbo.F_BAB_L_GEN_ACCT_STMT_summary),
@sql_execution			nvarchar(max),
@count					bigint,
@summary_count			bigint = 0,
@summary_table			varchar(550)

set nocount on

set @summary_table = replace(replace(@db_sch_table,']',''),'[','')
set @summary_table = '[master].['+master.dbo.vertical_array(@summary_table,'.',2)+'].['+master.dbo.vertical_array(@summary_table,'.',3)+'_summary]'

set @sql_execution = 'select @count_summary = max(max_RECID) from '+@summary_table
exec sp_executesql @sql_execution, N'@count_summary bigint output', @count_summary = @max_ID output

set @sql_execution = 'select @total_rows = count(*) from '+@db_sch_table
exec sp_executesql @sql_execution, N'@total_rows bigint output', @total_rows = @count output

while @summary_count < @count
begin

set @sql_execution = 'select @count = count(*) * '+cast(@bulk as varchar(30))+'
from '+@summary_table
exec sp_executesql @sql_execution, N'@count bigint output', @count = @summary_count output

create table #Temporary_ARCHIVE_Table ([ID] varchar(255) primary key)

set @sql_execution = N'
select '+@clustered_index_key+'
from (
select top '+cast(@bulk as nvarchar(20))+' '+@clustered_index_key+'
from '+@db_sch_table+'
where '+@clustered_index_key+' > '+''''+cast(isnull(@max_ID,0) as nvarchar(255))+''''+'
order by '+@clustered_index_key+')a'

--print(@sql_execution)

insert into #Temporary_ARCHIVE_Table
exec sp_executesql @sql_execution

select 
@min_ID			= min([ID]), 
@max_ID			= max([ID])
from #Temporary_ARCHIVE_Table

set @sql_execution = 'insert into '+@summary_table+' (min_RECID, max_RECID) values ('+''''+@min_ID+''''+' , '+''''+@max_ID+''''+')'
exec sp_executesql @sql_execution

drop table #temporary_ARCHIVE_table
end

set nocount off
end
go



