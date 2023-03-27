select top 50
database_name, backup_type, convert(varchar(10),backup_start_date,120) backup_date,
sum(is_next_backup_failed) how_many_failures
from (
select 
database_name, backup_type, 
backup_start_date, backup_finish_date, backup_duration, 
next_backup_start, 
case when datediff(s, backup_start_date, next_backup_start) > (15 * 60) then 1 else 0 end is_next_backup_failed
from (
select top 100 percent * 
from (
select --top 10
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
case when LAG(backup_start_date, 1,1) over(order by backup_start_date desc) = '1900-01-02 00:00:00.000' then getdate() else LAG(backup_start_date, 1,1) over(order by backup_start_date desc) end next_backup_start
from msdb.dbo.backupset bs inner join msdb.dbo.backupmediafamily bmf
on bs.media_set_id = bmf.media_set_id)a
where db_id(database_name) > 4
order by backup_start_date desc)a
)b
where backup_type = 'log'
group by database_name, backup_type, convert(varchar(10),backup_start_date,120) 
order by convert(varchar(10),backup_start_date,120) desc
