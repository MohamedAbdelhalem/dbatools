-- prequisties
 
use master
go
DROP TABLE [dbo].[migration_log_files]
GO
CREATE TABLE [dbo].[migration_log_files](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[file_datetime] [datetime] NULL,
	[backup_file_name] [varchar](max) NULL,
	[full_backup_file_name] [varchar](max) NULL,
	[is_done] [bit] NULL,
	[start_eq_or_af] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[migration_log_files] ADD  DEFAULT ((0)) FOR [is_done]
GO
ALTER TABLE [dbo].[migration_log_files] ADD  DEFAULT ((1)) FOR [start_eq_or_af]
GO
declare @backup_root_path varchar(1000) = '\\npci2.d2fs.albilad.com\'
--declare @exclude_databases varchar(max) = 'master,model,msdb,T24Prod_Clone'
--declare @just_those_databases varchar(max) = 'all'se
declare @main_root_backup_name varchar(300) = 'T24_BACKUP_' --e.g. T24_BACKUP_2024 or T24_BACKUP_2025
 
--variables
declare @backup_folders table (output_text varchar(max), path varchar(max))
declare @log_backup_folders table (output_text varchar(max), path varchar(max), db_name varchar(500))
declare @Path_Exist table (output_text varchar(max))
 
declare 
@xp_cmdshell_root		varchar(1500),
@log_backup_db_path		varchar(1500),
@folder_db_name			varchar(500)
 
declare 
@subfolder	varchar(1000),
@subfolder2 varchar(1000),
@day		int,
@month_name int,
@year		int,
@cmd		varchar(1000)
 
set nocount on
declare @getdate datetime = getdate()
--verify condition
--select day(@getdate), day(dateadd(s,-1,convert(varchar(10),dateadd(month,1,dateadd(day,-day(@getdate)+1,@getdate)),120)))
 
--if current day = last day on the current month e.g. 28/02 or 30/09 or 31/10
--then checking this month and the next month
if day(@getdate) = day(dateadd(s,-1,convert(varchar(10),dateadd(month,1,dateadd(day,-day(@getdate)+1,@getdate)),120)))
begin
set @subfolder = isnull(@main_root_backup_name+cast(year(@getdate) as varchar(10))+'\','')+'Logs\'+cast(year(@getdate) as varchar(10))+'\'+cast(FORMAT(@getdate,'MMMM') as varchar(10))+'\'
set @subfolder2 = isnull(@main_root_backup_name+cast(year(@getdate+1) as varchar(10))+'\','')+'Logs\'+cast(year(@getdate+1) as varchar(10))+'\'+cast(FORMAT(@getdate+1,'MMMM') as varchar(10))+'\'
--select @subfolder, @subfolder2
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Test-Path '+@backup_root_path+@subfolder+'}"'''
insert into @Path_Exist
exec(@cmd)
 
if (select top 1 output_text from @Path_Exist where output_text is not null) = 'true'
begin
	set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+@subfolder+'"'+''''
	insert into @backup_folders (output_text)
	exec(@xp_cmdshell_root)
	update @backup_folders set path = @backup_root_path+@subfolder where path is null
end
 
delete from @Path_Exist
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Test-Path '+@backup_root_path+@subfolder2+'}"'''
insert into @Path_Exist
exec(@cmd)
 
if (select top 1 output_text from @Path_Exist where output_text is not null) = 'true'
begin
	set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+@subfolder2+'"'+''''
	insert into @backup_folders (output_text)
	exec(@xp_cmdshell_root)
	update @backup_folders set path = @backup_root_path+@subfolder2 where path is null
end
end
else
--if current day = day 1 on the current month e.g. 01/02 or 01/09 or 30110
--then checking this month and the pervious month
if day(@getdate) = 1
begin
set @subfolder = isnull(@main_root_backup_name+cast(year(@getdate) as varchar(10))+'\','')+'Logs\'+cast(year(@getdate) as varchar(10))+'\'+cast(FORMAT(@getdate,'MMMM') as varchar(10))+'\'
set @subfolder2 = isnull(@main_root_backup_name+cast(year(@getdate-1) as varchar(10))+'\','')+'Logs\'+cast(year(@getdate-1) as varchar(10))+'\'+cast(FORMAT(@getdate-1,'MMMM') as varchar(10))+'\'
--select @subfolder, @subfolder2
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Test-Path '+@backup_root_path+@subfolder+'}"'''
insert into @Path_Exist
exec(@cmd)
 
if (select top 1 output_text from @Path_Exist where output_text is not null) = 'true'
begin
	set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+@subfolder+'"'+''''
	insert into @backup_folders (output_text)
	exec(@xp_cmdshell_root)
	update @backup_folders set path = @backup_root_path+@subfolder where path is null
end
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Test-Path '+@backup_root_path+@subfolder+'}"'''
insert into @Path_Exist
exec(@cmd)
 
if (select top 1 output_text from @Path_Exist where output_text is not null) = 'true'
begin
	set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+@subfolder2+'"'+''''
	insert into @backup_folders (output_text)
	exec(@xp_cmdshell_root)
	update @backup_folders set path = @backup_root_path+@subfolder2 where path is null
end
 
end
else
--current day != 1 or 31
begin
set @subfolder = isnull(@main_root_backup_name+cast(year(@getdate) as varchar(10))+'\','')+'Logs\'+cast(year(@getdate) as varchar(10))+'\'+cast(FORMAT(@getdate,'MMMM') as varchar(10))+'\'
 
--select @subfolder, @subfolder2
set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+@subfolder+'"'+''''
insert into @backup_folders (output_text)
exec(@xp_cmdshell_root)
update @backup_folders set path = @backup_root_path+@subfolder where path is null
 
end
 
insert into dbo.migration_log_files (file_datetime, backup_file_name, full_backup_file_name)
select file_creation_date, backup_file_name, log_backup_file_name
from (
select log_backup_file_name backup_file_name, path+log_backup_file_name log_backup_file_name, file_creation_date
--,row_number() over(partition by db_name order by file_creation_date desc) id
from (
select file_creation_date, path, ltrim(rtrim(substring(output_text, charindex(' ', output_text)+1, len(output_text)))) log_backup_file_name
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text , 
convert(datetime,ltrim(rtrim(substring(output_text, 1, charindex('M ', output_text)))),120) file_creation_date, path
from @backup_folders
where output_text not like '%<DIR>%'
and output_text like '%M  %'
)a)b)c
except
select file_datetime, backup_file_name, full_backup_file_name
from dbo.migration_log_files 
order by file_creation_date
 
 
--select count(*), backup_file_name from dbo.migration_log_files group by backup_file_name having count(*) > 1
