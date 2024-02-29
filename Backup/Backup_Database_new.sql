USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Backup_Database]    Script Date: 2/29/2024 3:00:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[Backup_Database](
@database_name	varchar(max) = '*',
@except_db		varchar(max) = '0',
@backup_type	varchar(1),
@full_path		varchar(2000),
@execution_type	int)
as
begin

declare @dbs_list table (database_name varchar(400), allowed_backups char(1)) 
declare @dbs table (database_name varchar(400)) 
declare 
@db_name           varchar(300), 
@sql               varchar(2000), 
@file_name         varchar(1000), 
@week_number       varchar(10), 
@backup_start      varchar(30), 
@date              varchar(10), 
@time              varchar(10), 
@ampm              varchar(2),
@diff_seq          varchar(5),
@log_seq           varchar(5)

insert into @dbs_list
select db.name, case 'L' when 'L' then case when db.recovery_model_desc in ('Simple','bulk-logged') then 'N' else 'Y' end else 'Y' end allow_log_backup
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

open backup_cursor
fetch next from backup_cursor into @db_name
while @@fetch_status = 0
begin

set @sql = 'BACKUP '+case @backup_type 
when 'F' then 'DATABASE' 
when 'D' then 'DATABASE' 
when 'L' then 'LOG' end + ' ['+@db_name+'] 
TO  DISK = N'+''''+@full_path+'\'+replace(@db_name,'''','')+'\'+replace(@db_name,'''','')+'_'+@file_name+'.bak'' 
WITH '+case @backup_type 
when 'F' then '' 
when 'L' then '' 
when 'D' then 'DIFFERENTIAL, ' end+ 'NOFORMAT, NOINIT,  
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
 
end
