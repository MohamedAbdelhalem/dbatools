CREATE Procedure [dbo].[sp_schedule_modifier]
(@job_name varchar(500), @modified_date datetime, @enable bit = 1)
as
begin
declare @job_id nvarchar(100), @schedule_id int, @date int, @time int

select @job_id = j.job_id, @schedule_id = schedule_id
from msdb..sysjobs j inner join msdb..sysjobschedules js
on j.job_id = js.job_id
where name = @job_name

select 
@date = convert(varchar(10),@modified_date,112), 
@time = replace(convert(varchar(10),@modified_date,108),':','')

EXEC msdb.dbo.sp_attach_schedule @job_id=@job_id,@schedule_id=@schedule_id

EXEC msdb.dbo.sp_update_schedule @schedule_id=@schedule_id, 
@enabled = @enable, 
@active_start_date = @date, 
@active_start_time = @time
end