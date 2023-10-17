go
:CONNECT 10.1.102.1
go
declare @database_name varchar(500) = 'T24Prod'
select top 1
rh.destination_database_name destination_name, 
case rh.restore_type when 'D' then 'Full' when 'I' then 'Differential' when 'L' then 'Log' end restore_type,  
SERVERPROPERTY('MachineName') Server_name,case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end backup_file_name,
rh.restore_date,
case 
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 1)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 2)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 3)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 4)'
end server_type,
convert(varchar(10),convert(datetime,substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),1,8),120),120)+' '+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),13,2) backup_date,
master.dbo.numbersize(bs.backup_size,'byte') backup_size,
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
go
:CONNECT 10.1.102.2
go
declare @database_name varchar(500) = 'T24Prod'
select top 1
rh.destination_database_name destination_name, 
case rh.restore_type when 'D' then 'Full' when 'I' then 'Differential' when 'L' then 'Log' end restore_type,  
SERVERPROPERTY('MachineName') Server_name,case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end backup_file_name,
rh.restore_date,
case 
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 1)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 2)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 3)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 4)'
end server_type,
convert(varchar(10),convert(datetime,substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),1,8),120),120)+' '+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),13,2) backup_date,
master.dbo.numbersize(bs.backup_size,'byte') backup_size,
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
go
:CONNECT 10.33.102.1
go
declare @database_name varchar(500) = 'T24Prod'
select top 1
rh.destination_database_name destination_name, 
case rh.restore_type when 'D' then 'Full' when 'I' then 'Differential' when 'L' then 'Log' end restore_type,  
SERVERPROPERTY('MachineName') Server_name,case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end backup_file_name,
rh.restore_date,
case 
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 1)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 2)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 3)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 4)'
end server_type,
convert(varchar(10),convert(datetime,substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),1,8),120),120)+' '+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),13,2) backup_date,
master.dbo.numbersize(bs.backup_size,'byte') backup_size,
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
go
:CONNECT 10.33.102.2
go
declare @database_name varchar(500) = 'T24Prod'
select top 1
rh.destination_database_name destination_name, 
case rh.restore_type when 'D' then 'Full' when 'I' then 'Differential' when 'L' then 'Log' end restore_type,  
SERVERPROPERTY('MachineName') Server_name,case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end backup_file_name,
rh.restore_date,
case 
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 1)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D1' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+'  - PDC (node 2)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V1' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 3)'
when left(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'D2' and right(cast(SERVERPROPERTY('MachineName') as varchar(500)),2) = 'V2' then cast(connectionproperty('local_net_address') as varchar(15))+' - SDC (node 4)'
end server_type,
convert(varchar(10),convert(datetime,substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),1,8),120),120)+' '+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(bmf.physical_device_name),charindex('.',REVERSE(bmf.physical_device_name))+1, CHARINDEX('_',REVERSE(bmf.physical_device_name)) - charindex('.',REVERSE(bmf.physical_device_name))-1 )),13,2) backup_date,
master.dbo.numbersize(bs.backup_size,'byte') backup_size,
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
