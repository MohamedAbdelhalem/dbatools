--use msdb
--go
--DROP TABLE [dbo].[table_sizing]
--go
--CREATE TABLE [dbo].[table_sizing](
--[id] [int] IDENTITY(1,1) NOT NULL,
--[table_name] [varchar](500) NULL,
--[rows] float NULL,
--[avg_row_count] [float] NULL,
--[avg_row_size] [varchar](255) NULL,
--[percent] [float] NULL,
--[avg_row_count_pct] [varchar](255) NULL,
--[avg_row_size_plus_%] [varchar](255) NULL,
--[insert_date] [datetime] NULL default getdate()
--) ON [PRIMARY]
--go

select avg(rows)
from (
select count(*) rows, fileid, pageid
from (
select
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid
from [dbo].[F_BAB_L_REPORTS_LINES]
where recid between 'LD.CASHFLOW-21013-LD2300900599-0001' and 'LD.CASHFLOW-21054-LD2222600341-0019')a
group by fileid, pageid)b
go

use [linq2Albilad_v3]
go
declare 
@top int = 1000000,
@rows float,
@avg_row_count float, @pct float = 15, @sql nvarchar(max), @table_name varchar(500), @param nvarchar(100) = '@avg float output'
declare i cursor fast_forward
for
select top 100 percent '['+schema_name(schema_id)+'].['+name+']' AS TableName
from sys.tables
order by '['+schema_name(schema_id)+'].['+name+']'

open i
fetch next from i into @table_name
while @@FETCH_STATUS = 0
begin
set @sql = N'
select @avg = avg(rows)
from(
select count(*) rows, fileid, pageid
from (
select top '+cast(@top as nvarchar(20))+'
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),'')'',''''),''('',''''),'':'',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),'')'',''''),''('',''''),'':'',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),'')'',''''),''('',''''),'':'',3) slotid
from '+@table_name+' with (nolock))a
group by fileid, pageid)b'

print(@sql)
exec sp_executesql @sql, @param, @avg = @avg_row_count output 

select @rows = max(rows) from sys.partitions where object_id = object_id(@table_name)

Insert into msdb.dbo.table_sizing
(table_name,rows,avg_row_count,avg_row_size,[percent],avg_row_count_pct,[avg_row_size_plus_%])
select @table_name, @rows, @avg_row_count avg_row_count, master.dbo.numberSize(8060.0 / @avg_row_count, 'byte') avg_row_size, @pct [percent],round((@avg_row_count - ((@avg_row_count *10.0) /100)),0) avg_row_count_pct,
master.dbo.numbersize(round(8060.0 / (@avg_row_count - ((@avg_row_count *10.0) /100)),0) ,'byte') [avg_row_size_plus_%]

fetch next from i into @table_name
end
close i
deallocate i





--select * from @tbl