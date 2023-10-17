use master 
go
CREATE TABLE [dbo].[table_insert_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[from_id] [bigint] NULL,
	[dump_file_name] [varchar](2000) NULL,
	[date_time] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[table_insert_log] ADD  DEFAULT (getdate()) FOR [date_time]
GO
use master 
go
CREATE Procedure dbo.sp_import_dump_files
(@server_ip varchar(100), @db_name varchar(300), @files_location varchar(1000))
as 
begin
declare @xp_cmdshell varchar(1000)
declare @table table (output_text varchar(max))
declare @export_files table (id int identity(1,1), dump_file_name varchar(2000), from_id bigint)
set nocount on
set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@files_location+'"'+''''
insert into @table
exec (@xp_cmdshell)

insert into @export_files
select output_Text dump_file_name, cast(substring(from_id, 1, charindex('_',from_id)-1) as bigint) from_id
from (
select output_text, substring(output_text, charindex('_from_',output_text)+6, len(output_text)) from_id
from (
select substring(output_text, charindex(' ',output_text)+1, len(output_text)) output_text
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
where dump_file_name not in (select dump_file_name from dbo.table_insert_log)
order by cast(substring(reverse(substring(reverse(dump_file_name),1,charindex('_',reverse(dump_file_name))-1)), 1, charindex('.',reverse(substring(reverse(dump_file_name),1,charindex('_',reverse(dump_file_name))-1)))-1) as int) 

open i
fetch next from i into @id, @dump, @from_id, @count_of_files
while @@FETCH_STATUS = 0
begin
if @id != @count_of_files
begin
	set @sql = 'xp_cmdshell ''sqlcmd -S '+@server_ip+' -E -d '+@db_name+' -i "'+@files_location+'\'+@dump+'"'+''''
	--print(@sql)
	exec(@sql)
	insert into dbo.table_insert_log (from_id,dump_file_name) values (@from_id, @dump)
end
fetch next from i into @id, @dump, @from_id, @count_of_files
end
close i
deallocate i
set nocount off
end

go


--truncate table T24PROD_UAT.dbo.[FT$HIS_20220705_RECS.BKP]
--truncate table master.dbo.table_insert_log

select * from master.dbo.table_insert_log
order by id desc
go
--exec sp_import_dump_files @server_ip = '10.38.10.41', @db_name = 'T24_R21UAT', @files_location = '\\npci2.d2fs.albilad.com\DBTEMP\T24DBXtremIOT3\T24_support\FULL\export'

