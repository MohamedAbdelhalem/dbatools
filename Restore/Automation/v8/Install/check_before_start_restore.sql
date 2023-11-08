declare 
@before_date			datetime,
@db_restore_name		varchar(500),
@username				varchar(500),
@workaround_locations	varchar(3000),
@is_using_workaround	bit,
@dbsync					int

select before_date from master.dbo.auto_restore_job_parameters

select 
@before_date			          = before_date,
@db_restore_name		        = db_restore_name,
@username				            = username,
@dbsync					            = isAG,
@workaround_locations 	    = workaround_locations,
@is_using_workaround	      = case when @before_date < '2022-12-01' then 0 else 1 end
from master.dbo.auto_restore_job_parameters

exec dbo.automatic_database_restore
@before_date				        = @before_date, 
@db_restore_name			      = @db_restore_name,
@username					          = @username,
@locations					        = @workaround_locations,
@isAG						            = @dbsync,
@workaround_loc				      = @is_using_workaround,		-- 0 before December
@continue_after_file_number = 0,
@action						          = 4

--if check outcome is good then execute the below procedure
--exec master.dbo.sp_schedule_modifier @job_name='Automatic Restore Job',@after='s',@amount=10

--select * from  dbo.error_message(@@spid)
