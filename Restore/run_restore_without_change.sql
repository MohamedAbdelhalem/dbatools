use master
go
select * from [master].[dbo].[auto_restore_job_parameters] 
go
declare @date_update datetime = '1900-01-01'
if convert(varchar(10),@date_update,120) != '1900-01-01'
begin
update [master].[dbo].[auto_restore_job_parameters] set before_date = @date_update

declare @date datetime;
select top 1 @date = before_date 
from dbo.auto_restore_job_parameters

select @date

exec [dbo].[update_backups_metadata] @before_date = @date

exec [master].[dbo].[sp_schedule_modifier] @job_name='Automatic Restore Job',@after='s',@amount=10
end

