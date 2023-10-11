select j.name job_name, step_id, step_name, command, subsystem
from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobsteps js
on j.job_id = js.job_id
where command like '%F_BAB_L_CTX_DUP_PROCESS_1%'