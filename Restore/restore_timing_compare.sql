select 
COUNT(*) backup_files, 
avg(COUNT(*)) over() avg_backup_files, 
restore_date, 
master.dbo.duration('s',SUM(restore_duration)) overall_restore_duration, 
master.dbo.numbersize(sum(backup_size)/1024.0/1024.0,'m') total_backup_size
from (
select --count(*), 
convert(varchar(10),rh.restore_date,120) restore_date, 
--master.dbo.duration('s',
case when rh.stop_at is null then datediff(s,rh.restore_date,isnull((select restore_date from msdb.dbo.restorehistory where restore_history_id = rh.restore_history_id + 1),getdate())) else 0 end
--) 
restore_duration,
--master.dbo.numbersize(
case when rh.stop_at is null then bs.backup_size else 0 end backup_size

from msdb.dbo.restorehistory rh inner join msdb.dbo.backupset bs
on rh.backup_set_id = bs.backup_set_id
inner join msdb.dbo.backupmediafamily bmf
on bmf.media_set_id = bs.backup_set_id)a
group by restore_date
order by restore_date desc
--order by rh.restore_date-- desc
