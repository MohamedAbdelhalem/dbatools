declare @table table (
id int, database_name varchar(1000), backup_type varchar(30), backup_start_date datetime, backup_finish_date datetime, backup_duration varchar(50), is_damaged bit, is_force_offline bit, 
server_name varchar(255), user_name varchar(255), recovery_model varchar(255), backup_size varchar(255), backup_compressed_size varchar(255), [compression %] int, physical_device_name varchar(2000), device_type varchar(255))

insert into @table 
select id, database_name, backup_type, backup_start_date, backup_finish_date, backup_duration, is_damaged, is_force_offline, server_name, user_name, recovery_model, backup_size, backup_compressed_size, [compression %], physical_device_name, device_type
from (
select top 1000
row_number() over(order by backup_start_date desc) id, 
database_name, 
case type 
when 'L' then 'Log'
when 'I' then 'Differential'
when 'D' then 'Full'
when 'F' then 'File or filegroup'
when 'G' then 'Differential file'
when 'P' then 'Partial'
when 'Q' then 'Differential partial'
else 'Others' end backup_type, 
backup_start_date, backup_finish_date, 
master.dbo.duration('s', datediff(s,backup_start_date,backup_finish_date)) backup_duration, 
is_damaged, is_force_offline,
server_name,
user_name, recovery_model, master.dbo.numbersize(backup_size,'byte') backup_size, 
master.dbo.numbersize(compressed_backup_size,'byte') backup_compressed_size , 
cast(cast(compressed_backup_size as float) / cast(backup_size as float) * 100.0 as numeric(10,2)) [compression %], 
physical_device_name, case device_type 
when 2 then 'Disk' 
when 4 then 'Tape' 
when 7 then 'Virtual device' 
when 9 then 'Azure Storage' 
when 105  then 'A permanent backup device' 
end device_type
from msdb.dbo.backupset bs inner join msdb.dbo.backupmediafamily bmf
on bs.media_set_id = bmf.media_set_id
where db_id(database_name) > 4
order by backup_start_date desc)a

select row_number() over(partition by database_name order by database_name, backup_start_date desc) id,
database_name, backup_type, backup_start_date, backup_finish_date, backup_duration, is_damaged, is_force_offline, server_name, user_name, recovery_model, backup_size, backup_compressed_size, [compression %], physical_device_name, device_type
from @table
where id in (
select min(id)
from @table
group by database_name, backup_type)
order by database_name, backup_start_date desc