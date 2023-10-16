use master
go
declare @database_name varchar(500) = 'T24Prod'
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
where restore_date >= (select max(restore_date) 
						 from msdb.dbo.restorehistory rh2 inner join msdb.dbo.backupset bs2 
						 on rh2.backup_set_id = bs2.backup_set_id
						where restore_type = 'D'
						and bs2.database_name = @database_name) --last restore files since last full bakup restore
and bs.database_name = @database_name
order by rh.restore_date desc

select * from auto_restore_job_parameters

--if cast(connectionproperty('local_net_address') as varchar(30)) = '10.36.1.229'
--begin
--select COB_COMPLETE from [D1T24DBSQPWV2].[T24Prod].[dbo].[COB_COMPLETE]
--end

--select dense_rank() over(order by id, destination_name),
--* from (
--select 
--row_number() over(order by rh.restore_date desc) id,
--rh.destination_database_name destination_name, 
--case rh.restore_type when 'D' then 'Full' when 'I' then 'Differential' when 'L' then 'Log' end restore_type,  
--rh.restore_date, 
--master.dbo.duration('s',datediff(s,rh.restore_date,isnull((select restore_date from msdb.dbo.restorehistory where restore_history_id = rh.restore_history_id + 1),getdate()))) restore_duration,
--bs.backup_start_date original_backup_start_date, 
--bs.backup_finish_date original_backup_finish_date, 
--master.dbo.numbersize(bs.backup_size,'byte') backup_size,
--rh.stop_at, rh.stop_at_mark_name, rh.stop_before, rh.replace restore_with_replace
--from msdb.dbo.restorehistory rh inner join msdb.dbo.backupset bs
--on rh.backup_set_id = bs.backup_set_id)a
--order by restore_date desc
