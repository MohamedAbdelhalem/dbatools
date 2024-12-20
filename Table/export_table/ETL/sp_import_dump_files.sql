USE [master]
GO
if object_id('[dbo].[table_insert_log]') is not null
begin
drop table [dbo].[table_insert_log]
end
go
CREATE TABLE [dbo].[table_insert_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[from_id] [bigint] NULL,
	[dump_file_name] [varchar](2000) NULL,
	[date_time] [datetime] DEFAULT (getdate()) NOT NULL 
) ON [PRIMARY]
GO
if object_id('[dbo].[sp_import_dump_files]') is not null
begin
drop procedure [dbo].[sp_import_dump_files]
end
go

CREATE procedure [dbo].[sp_import_dump_files]
(@server_ip varchar(100), @db_name varchar(300), @files_location varchar(1000))
as 
begin
declare @xp_cmdshell varchar(1000)
declare @table table (output_text varchar(max))
declare @export_files table (id int identity(1,1), dump_file_name varchar(2000), from_id bigint, dump_file_size bigint)
set nocount on
set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@files_location+'"'+''''
insert into @table
exec (@xp_cmdshell)

insert into @export_files (dump_file_size, dump_file_name, from_id)
select size, output_Text dump_file_name, cast(substring(from_id, 1, charindex('_',from_id)-1) as bigint) from_id
from (
select size, output_text, substring(output_text, charindex('_from_',output_text)+6, len(output_text)) from_id
from (
select cast(replace(substring(output_text,1, charindex(' ',output_text)-1),',','') as bigint) size, substring(output_text, charindex(' ',output_text)+1, len(output_text)) output_text
from (
select ltrim(rtrim(substring(output_text, charindex('M ', output_text)+1, len(output_text)))) output_text
from @table
where output_text like '%M %'
and output_text not like '%<DIR>%')a)b)c
order by from_id

declare @dump varchar(1000), @sql varchar(max), @from_id bigint, @count_of_files int, @id int
declare i cursor fast_forward
for
select id, dump_file_name, from_id, count(*) over()
from @export_files
where from_id not in (select from_id from dbo.table_insert_log)
and dump_file_size > 0
order by id 

open i
fetch next from i into @id, @dump, @from_id, @count_of_files
while @@FETCH_STATUS = 0
begin

set @sql = 'xp_cmdshell ''sqlcmd -S '+@server_ip+' -E -d '+@db_name+' -i "'+@files_location+'\'+@dump+'"'+' > nul '+''''
--print(@sql)
exec(@sql)
insert into dbo.table_insert_log (from_id,dump_file_name) values (@from_id, @dump)

fetch next from i into @id, @dump, @from_id, @count_of_files
end
close i
deallocate i
set nocount off
end
go

exec [import_table].dbo.sp_table_size '','FBNK_AC_LOCKED_EVENTS_ARC_FEB2019'

select cast(cast(count(*) as float) / 7365.0 * 100.0 as numeric(5,2)) percent_complete, master.dbo.time_to_complete(count(*), 7365, min(date_time)) time_to_complete 
from [dbo].[table_insert_log]


