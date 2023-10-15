select j.name job_name, js.step_name, command, s.* 
from msdb..sysjobs j inner join msdb..sysjobsteps js
on j.job_id = js.job_id
cross apply master.dbo.Separator(command, char(10)) s
where command like '%F_ENJ_T_O201%'
order by job_name, s.id
