select 
j.name job_name, ja.last_executed_step_id, js.step_name [last_execut(ing:ed)_step_name], 
case when ja.stop_execution_date is null then 1 else 0 end is_running, 
ja.last_executed_step_date, 
--case when ja.stop_execution_date is null then 'RUNNING' else master.dbo.duration('s',datediff(s, ja.last_executed_step_date, getdate())) end status,
case when ja.stop_execution_date is null then 'RUNNING' else 'Done' end status,
master.dbo.duration('s',case when ja.stop_execution_date is null then datediff(s, ja.last_executed_step_date, getdate()) else 0 end) last_step_duration, 
master.dbo.duration('s',case when ja.stop_execution_date is null then datediff(s,ja.start_execution_date, getdate()) else 0 end) running_overall_duration
from msdb.dbo.sysjobs j left outer join msdb.dbo.sysjobactivity ja
on j.job_id = ja.job_id
left outer join msdb.dbo.sysjobsteps js
on ja.last_executed_step_id = js.step_id
and ja.job_id = js.job_id
where last_executed_step_date in  (select last_executed_step_date 
									 from (select max(last_executed_step_date) last_executed_step_date, name 
											 from msdb.dbo.sysjobactivity jja inner join msdb.dbo.sysjobs jj 
											   on jja.job_id = jj.job_id group by jj.name)a)
--and j.name in ('PRODmfreportsdbBAB - Purge Monthly','BO_QC_REPORT_JOB')
order by is_running desc, job_name
--alter database [T24Prod] set single_user with rollback immediate
