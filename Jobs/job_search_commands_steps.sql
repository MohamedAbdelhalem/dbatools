declare 
@command_like_1 varchar(300) = 'sp_not',
@command_like_2 varchar(300) = null

if @command_like_2 is null
begin

select j.name, js.step_id, js.step_name, js.database_name, --js.command, 
sep.value step_command_readable
from msdb..sysjobs j inner join msdb..sysjobsteps js
on j.job_id = js.job_id
cross apply master..Separator(js.command, char(10))sep
where command like '%'+@command_like_1+'%'
--and database_name = 'T24Prod'
order by j.name, js.step_id, sep.id

end
else 
begin

select j.name, js.step_id, js.step_name, js.database_name, --js.command, 
sep.value step_command_readable
from msdb..sysjobs j inner join msdb..sysjobsteps js
on j.job_id = js.job_id
cross apply master..Separator(js.command, char(10))sep
where command like '%'+@command_like_1+'%'
and command like '%'+@command_like_2+'%'
--and database_name = 'T24Prod'
order by j.name, js.step_id, sep.id
end

