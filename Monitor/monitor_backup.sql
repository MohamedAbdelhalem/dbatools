use master
go
--create view monitor_backup
--as
select spid, percent_complete,
case
when s.text like '%backup database%' and s.text not like '%Differential%' then 'FULL'
when s.text like '%backup database%' and s.text like '%Differential%' then 'DIFF'
when s.text like '%backup log%' then 'LOG' end [backup_type], 
master.dbo.virtical_array(ltrim(rtrim(sep.value)),' ',3) database_name,
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
--(select count(*) from master.dbo.Separator(ltrim(rtrim(s.text)), Restore)) total_files,
dbo.duration('s', estimated_completion_time/1000) estimated_completion_time,
s.text, 
substring(reverse(substring(reverse(replace(s.text,CHAR(9),'')),1, charindex('\',reverse(replace(s.text,CHAR(9),'')))-1)), 1, 
charindex(' ',reverse(substring(reverse(replace(s.text,CHAR(9),'')),1, charindex('\',reverse(replace(s.text,CHAR(9),'')))-1)))-1) [backup_file_name], 
waittime, lastwaittype, blocked, command, r.status
from sys.sysprocesses p with (nolock) cross apply sys.dm_exec_sql_text(p.sql_handle)s
left outer join sys.dm_exec_requests r with (nolock)
on p.spid = r.session_id
inner join sys.dm_exec_connections c with (nolock)
on p.spid = c.session_id
cross apply master.dbo.Separator(substring(s.text,p.stmt_start/2+1, case when p.stmt_end < 0 then len(s.text) else p.stmt_end/2+1 end), char(10)) sep
where command like 'backup%'
and (sep.value like '%BACKUP database%' 
or sep.value like '%BACKUP log%') 
and sep.id = 1


--kill 474
--select round(r.percent_complete,2), p.spid, cmd command, dbo.duration(s, estimated_completion_time/1000) estimated_completion_time--, sep.id, sep.value sql_text
--from sys.sysprocesses p inner join sys.dm_exec_requests r
--on p.spid = r.session_id
--cross apply sys.dm_exec_sql_text(p.sql_handle) s
----cross apply master.dbo.Separator(substring(s.text,stmt_start/2+1, case when stmt_end < 0 then len(s.text) else stmt_end/2+1 end), char(10)) sep 
--where cmd like backup%
--order by spid--, sep.id

