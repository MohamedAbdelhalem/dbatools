use master
go
--create view active_job_status
--as
select job_name, step_name,
case job_status when 1 then master.dbo.duration('s', datediff(s, start_execution_date, getdate())) else null end job_duration
from (
select j.job_id, j.name job_name, ja.start_execution_date, case 
when ja.start_execution_date is null												then 0
when ja.start_execution_date is not null	and ja.stop_execution_date is not null	then 0
when ja.start_execution_date is not null	and ja.stop_execution_date is null		then 1
end job_Status,
js.step_name
from msdb.dbo.sysjobs j
inner join msdb.dbo.sysjobactivity ja
on j.job_id = ja.job_id
left outer join msdb.dbo.sysjobsteps js
on js.job_id = ja.job_id
and js.step_id = ja.last_executed_step_id
where session_id = (select max(session_id) from msdb.dbo.sysjobactivity))a
where job_status = 1
