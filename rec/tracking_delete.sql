SELECT
[id],[Current LSN],[Operation],[Context], 
convert(varchar(10),convert(datetime,convert(varchar(10),substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),1,8),111),111),120)+' '+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),09,2)+':'+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),11,2)+':'+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),13,2) backup_date_window,
--dbo.Hex_to_Text([RECID]) [RECID_H]
[RECID_H]
FROM [master].[dbo].[TLog_tracking] 
where [RECID_H] like 'AML%'
order by id

SELECT 
count(*) deleted_row_count, substring([RECID_H],1,charindex('.',[RECID_H])-1) RECID_first_dot
FROM [master].[dbo].[TLog_tracking] 
group by substring([RECID_H],1,charindex('.',[RECID_H])-1)
order by substring([RECID_H],1,charindex('.',[RECID_H])-1)


SELECT 
master.dbo.format(count(*),-1) deleted_rows, convert(varchar(10),convert(datetime,convert(varchar(10),substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),1,8),111),111),120)+' '+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),09,2)+':'+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),11,2)+':'+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),13,2) backup_date,
[backup_file_name]
FROM [master].[dbo].[TLog_tracking]
group by [backup_file_name]
order by [backup_file_name]

select id, 
convert(varchar(10),convert(datetime,convert(varchar(10),substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),1,8),111),111),120)+' '+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),09,2)+':'+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),11,2)+':'+
substring(reverse(substring(reverse(backup_file_name), 1, charindex('_',reverse(backup_file_name))-1)),13,2) backup_date,
start_time, end_time, 
master.dbo.duration('s',datediff(s,start_time,isnull(end_time,getdate()))) duration 
from master.dbo.TLog_tracking_monitor
