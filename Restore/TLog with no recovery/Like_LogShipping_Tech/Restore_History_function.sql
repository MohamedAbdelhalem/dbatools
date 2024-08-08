create function dbo.restore_history(@database_name varchar(500))
returns @table table (
destination_name varchar(500), 
restore_type  varchar(30),  
restore_date datetime, 
restore_duration varchar(50),
original_backup_start_date datetime, 
original_backup_finish_date datetime, 
stop_at varchar(300), 
backup_file_name varchar(max),
backup_size varchar(50),
stop_at_mark_name varchar(300), 
stop_before varchar(300), 
restore_with_replace int, 
full_path_of_backup_file varchar(max))
as
begin
insert into @table
select
rh.destination_database_name destination_name, 
case rh.restore_type when 'D' then 'Full' when 'I' then 'Differential' when 'L' then 'Log' end restore_type,  
rh.restore_date, 
case when rh.restore_date > lag(rh.restore_date,1,1) over(order by rh.restore_date desc) then NULL--,master.dbo.duration('s',datediff(s,rh.restore_date,GETDATE()))
else master.dbo.duration('s',datediff(s,rh.restore_date,lag(rh.restore_date,1,1) over(order by rh.restore_date desc))) end
restore_duration,
bs.backup_start_date original_backup_start_date, 
bs.backup_finish_date original_backup_finish_date, 
rh.stop_at, case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end backup_file_name,
master.dbo.numbersize(bs.backup_size,'byte') backup_size,
rh.stop_at_mark_name, rh.stop_before, rh.replace restore_with_replace, 
bmf.physical_device_name full_path_of_backup_file
from msdb.dbo.backupmediafamily bmf inner join msdb.dbo.backupset bs
on bmf.media_set_id = bs.media_set_id
inner join msdb.dbo.restorehistory rh
on rh.backup_set_id = bs.backup_set_id
--where restore_date >= (select max(restore_date) 
            -- from msdb.dbo.restorehistory rh2 inner join msdb.dbo.backupset bs2 
            -- on rh2.backup_set_id = bs2.backup_set_id
            --where restore_type = 'D'
            --and bs2.database_name = @database_name) --last restore files since last full bakup restore
--where restore_date >= '2023-10-28 00:00:00.000'
and bs.database_name = @database_name
order by rh.restore_date desc
return
end