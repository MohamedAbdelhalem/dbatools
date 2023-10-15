use master
go
select 
spid, 
percent_complete, /*full_text,*/ 
case when [restore_type] not in ('VERIFYONLY','HEADERONLY') then database_name else null end database_name, 
--case when [restore_type] not in ('VERIFYONLY','HEADERONLY') then convert(varchar(10), convert(datetime, substring(reverse(substring(backup_file, charindex('.',backup_file)+1, charindex('_',backup_file,charindex('.',backup_file)) -1- charindex('.',backup_file))),1,8), 111) , 120) end backup_file_time, 
--substring(reverse(substring(backup_file, charindex('.',backup_file)+1, charindex('_',backup_file,charindex('.',backup_file)) -1- charindex('.',backup_file))),9,6) backup_file_time2, 
[restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(backup_file,1,charindex('\',backup_file)-1)) backup_file,
waittime, lastwaittype, blocked, command, status
from (
select spid, text, percent_complete, [restore_type], duration, time_to_complete, estimated_completion_time,
replace(replace(database_name,']',''),'[','') database_name,
reverse(replace(replace(substring(text,1, charindex('''', text,6)),'N''','') ,'''','')) backup_file,
waittime, lastwaittype, blocked, command, status, full_text
from (
select spid, percent_complete,
case when len(substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end)) < 10 then 
case 
when s.text like '%restore database%' and s.text like '%move%' then 'FULL'
when s.text like '%restore database%' and s.text not like '%move%' then 'DIFF'
when s.text like '%restore log%' then 'LOG' 
when s.text like '%restore VerifyOnly%' then 'VERIFYONLY' 
when s.text like '%restore headeronly%' then 'HEADERONLY' 
end 
else 
case 
when substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) like '%restore database%' and substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) like '%move%' then 'FULL'
when substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) like '%restore database%' and substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) not like '%move%' then 'DIFF'
when substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) like '%restore log%' then 'LOG' 
when substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) like '%restore VerifyOnly%' then 'VERIFYONLY' 
when substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end) like '%restore headeronly%' then 'HEADERONLY' 
end 
end
[restore_type], 
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
master.dbo.virtical_array((select top 1 ltrim(rtrim(value)) from master.dbo.Separator(ltrim(substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end)),char(10))
where id = 1),' ',3) database_name,
substring(s.text,charindex('=',s.text)+1,len(s.text)) text, 
ltrim(substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end)) full_text,
waittime, lastwaittype, blocked, command, r.status
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
inner join sys.dm_exec_connections c
on p.spid = c.session_id
where command like 'Restore%')a)b


--select * from sys.sysprocesses where spid = 57
--select * from restore_notification
--select * from sys.dm_io_pending_io_requests


--select spid, s.text, substring(s.text, r.statement_start_offset /2+1, case when r.statement_end_offset < 0 then len(s.text) else r.statement_end_offset/2+1 end)
--from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
--inner join sys.dm_exec_requests r
--on p.spid = r.session_id
