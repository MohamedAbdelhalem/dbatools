USE [master]
GO

CREATE Procedure [dbo].[Backup_Database](
@database_name	varchar(max) = '*',
@except_db		varchar(max) = '0',
@backup_type	varchar(1) = 'F',
@full_path		varchar(2000) = '\\10.10.10.10\Backup\backup_user_databases\',
@mirror_pathes	varchar(max) = 'default',
@override		bit = 0,
@execution_type	int = 2)
as
begin

declare @path_exists table (id int identity(1,1), isexist varchar(20))
declare @dbs_list table (database_name varchar(400), allowed_backups char(1)) 
declare @dbs table (database_name varchar(400)) 
declare 
@db_name			varchar(300), 
@sql				varchar(2000), 
@file_name			varchar(1000), 
@week_number		varchar(10), 
@backup_start		varchar(30), 
@date				varchar(10), 
@time				varchar(10), 
@ampm				varchar(2),
@diff_seq			varchar(5),
@log_seq			varchar(5),
@path_end			bit,
@year				varchar(10),
@month				varchar(20),
@Pexists			varchar(4000),
@mkdir				varchar(4000),
@mirror				varchar(max),
@mirror_exists		bit = 0

set nocount on
if @mirror_pathes != 'default'
begin
select @mirror = isnull(@mirror+',
','')+ 'Disk = '+''''+value+''''
from master.dbo.Separator(@mirror_pathes,',')
order by id
set @mirror = 'MIRROR TO
'+@mirror
select @mirror_exists = case when @mirror is null then 0 else 1 end
end

insert into @dbs_list
select db.name, case @backup_type when 'L' then 
case when db.recovery_model_desc in ('Simple','bulk-logged') then 'N' else 'Y' end else 'Y' end allow_log_backup
from sys.databases db
where database_id > 4
and state_desc = 'ONLINE'

if @database_name != '*'
begin
insert into @dbs
select database_name
from @dbs_list
where database_name in (select ltrim(rtrim(value)) from master.dbo.Separator(@database_name,','))
and database_name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
and allowed_backups = case when @backup_type = 'L' then 'Y' else 'Y' end
end
else
begin
insert into @dbs
select database_name
from @dbs_list
where database_name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
and allowed_backups = case when @backup_type = 'L' then 'Y' else 'Y' end
end

declare backup_cursor cursor fast_forward
for
select database_name
from @dbs
order by database_name

set @date = replace(convert(varchar(10),convert(datetime, getdate(), 120), 120),'-','_')
set @time = replace(convert(varchar(5),convert(datetime, getdate(), 120), 108),':','_')
set @ampm = case when cast(substring(@time, 1, 2) as int) < 12 then 'AM' else 'PM' end
set @file_name = case @backup_type 
when 'F' then @date+'__'+@time+'_'+@ampm+'__'+'Full'
when 'D' then @date+'__'+@time+'_'+@ampm+'__'+'Diff'
when 'L' then @date+'__'+@time+'_'+@ampm+'__'+'TLog'
end

--select @date, @time, @ampm, @file_name
select 
@path_end = case when right(ltrim(rtrim(@full_path)),1) = '\' then 1 else 0 end, 
@year = cast(year(getdate()) as varchar(10)),
@month = DATENAME(month, getdate())

set @full_path = @full_path+case @path_end when 1 then '' else '\' end+@year+'\'+@month+'\'+case @backup_type 
when 'F' then 'FULL'
when 'D' then 'DIFF'
when 'L' then 'LOG'
end

open backup_cursor
fetch next from backup_cursor into @db_name
while @@fetch_status = 0
begin

set @Pexists = 'xp_cmdshell ''PowerShell.exe -Command "& {Test-Path -Path '+''''+''''+@full_path+'\'+replace(@db_name,'''','')+''''+''''+'}"'''
insert into @path_exists
exec(@pexists)
--print(@pexists)

if (select top 1 isexist from @path_exists where isexist is not null order by id desc) = 'False'
begin 
set @mkdir = 'xp_cmdshell ''PowerShell.exe -Command "& {mkdir '+''''+''''+@full_path+'\'+replace(@db_name,'''','')+''''+''''+'}"'''
exec(@mkdir)
--print(@mkdir)
end

set @sql = 'BACKUP '+case @backup_type 
when 'F' then 'DATABASE' 
when 'D' then 'DATABASE' 
when 'L' then 'LOG' end + ' ['+@db_name+'] 
TO  DISK = N'+''''+@full_path+'\'+replace(@db_name,'''','')+'\'+replace(@db_name,'''','')+'_'+@file_name+'.bak'' 
'+case @mirror_exists when 0 then '' else @mirror end+ case @mirror_exists when 0 then '' else '
' end+'WITH '+case @backup_type 
when 'F' then '' 
when 'L' then '' 
when 'D' then 'DIFFERENTIAL, ' end+ 
case @mirror_exists when 0 then 'NOFORMAT, '+case @override when 1 then 'INIT' else 'NOINIT' end+', ' 
else 'FORMAT, '+case @override when 1 then 'INIT,' else '' end end+' 
NAME = N'+''''+replace(@db_name,'''','')+'-'+case @backup_type 
when 'F' then 'Full'
when 'D' then 'Diff'
when 'L' then 'TLog'
end+' Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10'
 
if @execution_type = 1
begin
exec(@sql)
end
else if @execution_type = 2
begin
print(@sql)
print(' ')
end
else if @execution_type = 3
begin
exec(@sql)
print(@sql)
print(' ')
end

fetch next from backup_cursor into @db_name
end
close backup_cursor
deallocate backup_cursor

set nocount off
 
end
