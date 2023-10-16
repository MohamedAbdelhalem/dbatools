update dbo.auto_restore_job_parameters set before_date = '2023-09-09 03:00:00'
go

declare @date datetime;
select top 1 @date = before_date 
from dbo.auto_restore_job_parameters

exec [dbo].[update_backups_metadata]
@before_date				= @date
go

--if check outcome is good then execute the below procedure
go
exec master.dbo.sp_schedule_modifier @job_name='Automatic Restore Job',@after='s',@amount=10
