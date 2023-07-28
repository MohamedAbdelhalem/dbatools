select 
database_name, backup_type, 
backup_start_date, backup_finish_date, backup_duration, 
next_backup_start, 
is_next_backup_success, 
is_damaged, is_force_offline, server_name, user_name, recovery_model, backup_size, backup_compressed_size, [compression %], physical_device_name, device_type
from (
select 
database_name, backup_type, 
backup_start_date, backup_finish_date, backup_duration, 
next_backup_start, 
case 
when datediff(s, convert(datetime,convert(varchar(16),backup_start_date,120),120), convert(datetime,convert(varchar(16),next_backup_start,120),120)) > (15 * 60) 
and backup_type = 'Log'
then 0 else 1 end is_next_backup_success, 
is_damaged, is_force_offline, server_name, user_name, recovery_model, backup_size, backup_compressed_size, [compression %], physical_device_name, device_type
from (
select 
case 
when LAG(backup_type,1,1) over(order by backup_start_date desc) in ('Full','Differential') then LAG(backup_start_date, 2,1) over(order by backup_start_date desc) 
when LAG(backup_type,1,1) over(order by backup_start_date desc) = 'Log' then LAG(backup_start_date, 1,1) over(order by backup_start_date desc) 
end
next_backup_start,
* from (
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
--and backup_start_date between '2023-03-20' and '2023-03-21 00:00:00.000'
order by backup_start_date desc)a
--where db_id(database_name) = db_id('SS_BAB_Dev_new')
--where backup_type = 'full'
--where database_name = 'Data_Hub_Cortex_2019'
--where backup_type in ('full')
--and physical_device_name like '%Golden%'

--and backup_finish_date > convert(varchar(10), getdate(),120)
--order by backup_finish_date desc
--and physical_device_name like '%golden%'
--and database_name like 'BAB_MIS%'
)a)b


--@LogBackupPath = N'\\npci1.d1fs.albilad.com\T24_BACKUP_2023\Logs',
--@LogBackupPath = N'\\10.3.5.207\T24_BACKUP_2023\Logs',
--@DIFFBackupPath = N'\\npci1.d1fs.albilad.com\T24_BACKUP_2023\DIFF',
--@DIFFBackupPath = N'\\10.3.5.217\T24_BACKUP_2023\DIFF',
--@FullBackupPath = N'\\npci1.d1fs.albilad.com\T24_BACKUP_2023\FULL',
--@FullBackupPath = N'\\10.3.5.221\T24_BACKUP_2023\FULL',

