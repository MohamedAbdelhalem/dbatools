use master
go
--create table master.dbo.MESSAGE_ARCHIVE_summary (id int identity(1,1), min_MESSAGE_ID bigint, max_MESSAGE_ID bigint, min_CREATION_TIME datetime, max_CREATION_TIME datetime)
declare
@bulk					int = 1000,
@db_sch_table			nvarchar(500) = '[linq2Albilad_v3].[dbo].[MESSAGE_ARCHIVE]',
@columns				nvarchar(500) = '[MESSAGE_ID], [CREATION_TIME]',
@clustered_index_key	nvarchar(255) = '[MESSAGE_ID]',
@date_column			nvarchar(255) = '[CREATION_TIME]',
@loop					bigint = 0, 
@min_ID					bigint, 
@max_ID					bigint = (select max(max_MESSAGE_ID) from master.dbo.MESSAGE_ARCHIVE_summary),
@min_DATE_TIME			datetime,
@max_DATE_TIME			datetime,
@sql_execution			nvarchar(max)

while @loop < 1000
begin

create table #Temporary_ARCHIVE_Table ([ID] bigint primary key, [DATE_TIME] datetime)
create nonclustered index id_temp_date_time on #Temporary_ARCHIVE_Table ([DATE_TIME])

set @sql_execution = N'
select '+@columns+'
from (
select top '+cast(@bulk as nvarchar(20))+' '+@columns+'
from '+@db_sch_table+'
where '+@clustered_index_key+' > '+cast(isnull(@max_ID,0) as nvarchar(20))+'
order by '+@clustered_index_key+')a'
print(@sql_execution)

insert into #Temporary_ARCHIVE_Table
exec sp_executesql @sql_execution

select 
@min_ID			= min([ID]), 
@max_ID			= max([ID]), 
@min_DATE_TIME	= min([DATE_TIME]),
@max_DATE_TIME	= max([DATE_TIME])
from #Temporary_ARCHIVE_Table
where [DATE_TIME] < '2020-01-01 00:00:00'

insert into master.dbo.MESSAGE_ARCHIVE_summary (min_MESSAGE_ID, max_MESSAGE_ID, min_CREATION_TIME, max_CREATION_TIME)
values (@min_ID, @max_ID, @min_DATE_TIME ,@max_DATE_TIME)

drop table #temporary_ARCHIVE_table
set @loop = @loop + 1
end

--select id, master.dbo.format(min_MESSAGE_ID,-1) min_MESSAGE_ID, master.dbo.format(max_MESSAGE_ID,-1) max_MESSAGE_ID from master.dbo.MESSAGE_ARCHIVE_summary
select master.dbo.format(count(*),-1) total_rows from master.dbo.MESSAGE_ARCHIVE_summary
select master.dbo.format(count(distinct max_MESSAGE_ID),-1) total_rows from master.dbo.MESSAGE_ARCHIVE_summary

--select * from master.dbo.MESSAGE_ARCHIVE_summary

--258,300
--258,300

