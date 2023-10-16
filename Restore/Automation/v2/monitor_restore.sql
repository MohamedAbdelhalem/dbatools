USE [master]
GO

/****** Object:  View [dbo].[monitor_restore]    Script Date: 7/3/2022 10:13:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[monitor_restore]
as
select spid, percent_complete, database_name, backup_file, [restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(backup_file,1,charindex('\',backup_file)-1)) backup_file_name,
waittime, lastwaittype, blocked, command, status
from (
select spid, percent_complete, [restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(reverse(database_name),1,charindex(' ',reverse(database_name))-1)) database_name,
reverse(replace(replace(substring(text,1, charindex('''', text,6)),'N''','') ,'''','')) backup_file,
waittime, lastwaittype, blocked, command, status
from (
select spid, percent_complete,
case
when s.text like '%restore database%' and s.text like '%move%' then 'FULL'
when s.text like '%restore database%' and s.text not like '%move%' then 'DIFF'
when s.text like '%restore log%' then 'LOG' end [restore_type], 
dbo.duration('s',datediff(s, r.start_time, getdate())) duration, 
dbo.duration('s',
case when percent_complete = 0 then 0 else case when 
cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
< 0 then 0 else
cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
end end
) time_to_complete,
dbo.duration('s', estimated_completion_time/1000) estimated_completion_time,
ltrim(rtrim(substring(s.text,1, charindex('from',s.text)-4))) database_name,
substring(s.text,charindex('=',s.text)+1,len(s.text)) text,
waittime, lastwaittype, blocked, command, r.status
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
inner join sys.dm_exec_connections c
on p.spid = c.session_id
where command like 'Restore%')a)b
GO


