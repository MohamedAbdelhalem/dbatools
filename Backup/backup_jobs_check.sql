use master
go
if exists (select name from sys.objects where name = 'NumberSize')
begin 
drop function [dbo].[numberSize]
end
go
CREATE function [dbo].[numberSize]
(@number numeric(20,2), @type varchar(1))
returns varchar(100)
as
begin
declare @return varchar(100), @B numeric, @K numeric, @M numeric, @G numeric, @T numeric
set @b = 1024
set @k = 1048576
set @m = 1073741824
set @g = 1099511627776
set @t = 1125899906842624

if @type = 'B'
select @return = 
case 
when @number between    0 and @B then cast(round(cast(@number as float)/1,2) as varchar)+' Bytes'
when @number between @b+0 and @K then cast(round(cast(@number as float)/1024,2) as varchar)+' KB'
when @number between @k+0 and @M then cast(round(cast(@number as float)/1024/1024,2) as varchar)+' MB'
when @number between @m+0 and @G then cast(round(cast(@number as float)/1024/1024/1024,2) as varchar)+' GB'
when @number between @g+0 and @T then cast(round(cast(@number as float)/1024/1024/1024/1024,2) as varchar)+' TB'
end

else if @type = 'K'
begin
select @return = 
case 
when @number between    0 and @B then cast(round(cast(@number as float)/1,2) as varchar)+' KB'
when @number between @b+0 and @K then cast(round(cast(@number as float)/1024,2) as varchar)+' MB'
when @number between @k+0 and @M then cast(round(cast(@number as float)/1024/1024,2) as varchar)+' GB'
when @number between @m+0 and @G then cast(round(cast(@number as float)/1024/1024/1024,2) as varchar)+' TB'
end
end

else if @type = 'M'
select @return = 
case 
when @number between    0 and @B then cast(round(cast(@number as float)/1,2) as varchar)+' MB'
when @number between @b+0 and @K then cast(round(cast(@number as float)/1024,2) as varchar)+' GB'
when @number between @k+0 and @M then cast(round(cast(@number as float)/1024/1024,2) as varchar)+' TB'
end

else if @type = 'G'
select @return = 
case 
when @number between    0 and @B then cast(round(cast(@number as float)/1,2) as varchar)+' GB'
when @number between @b+0 and @K then cast(round(cast(@number as float)/1024,2) as varchar)+' TB'
end

else if @type = 'T'
select @return = 
case 
when @number between    0 and @B then cast(round(cast(@number as float)/1,2) as varchar)+' TB'
end

return @return
end
go

declare @type varchar(4), @backup char(1)
set @type = 'log'
select @backup = case @type 
when 'FULL' then 'D'
when 'DIFF' then 'I'
when 'LOG'  then 'L'
end
declare @min_backup_start_date datetime, @max_backup_start_date datetime
select 
@min_backup_start_date = min(backup_start_date), 
@max_backup_start_date = max(backup_start_date) 
from msdb.dbo.backupset 
where type in (@backup)

--select isnull(database_name, d.name) database_name, user_name, backup_start_date, type, backup_size, a.recovery_model, device_type, physical_device_name 
--from (
--select user_name, backup_start_date, type, database_name, backup_size, bs.recovery_model, bmf.device_type, bmf.physical_device_name
--from  msdb.dbo.backupset bs inner join msdb.dbo.backupmediafamily bmf
--on bs.media_set_id = bmf.media_set_id
--where type in (@backup)
--and backup_start_date between convert(varchar(10), @min_backup_start_date, 120) and convert(varchar(10), @min_backup_start_date + 1, 120)
--)a right outer join sys.databases d
--on d.name = a.database_name
--where database_id > 4
--order by user_name , database_name

select isnull(database_name, d.name) database_name, d.log_reuse_wait_desc, user_name, backup_start_date, type,
master.dbo.numberSize(cast((compressed_backup_size/1024) - 8 as bigint),'kb') compressed_backup_size,
master.dbo.numberSize(cast((backup_size/1024) as bigint),'kb') backup_size, a.recovery_model, physical_device_name 
from (
select user_name, backup_start_date, type, database_name, backup_size, bs.compressed_backup_size, bs.recovery_model, bmf.physical_device_name
from  msdb.dbo.backupset bs inner join msdb.dbo.backupmediafamily bmf
on bs.media_set_id = bmf.media_set_id
where type in (@backup)
and backup_start_date between convert(varchar(10), @max_backup_start_date, 120) and convert(varchar(10), @max_backup_start_date + 1, 120)
)a right outer join sys.databases d
on d.name = a.database_name
where database_id > 4
order by user_name , database_name, backup_start_date desc

