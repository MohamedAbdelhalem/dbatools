declare 
@before_date datetime,
@db_restore_name varchar(500),
@username varchar(500),
@loc varchar(10),
@sdc varchar(350) = '\\npci0.d0fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\',
@pdc varchar(350) = '\\npci0.d0fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\'

update master.dbo.auto_restore_job_parameters 
set before_date = dateadd(hour, 5, convert(varchar(10),getdate(),120))

--select * from master.dbo.auto_restore_job_parameters

select 
@before_date = before_date,
@db_restore_name = db_restore_name,
@username = username,
@pdc = replace(@pdc, '0', [location]), 
@sdc = replace(@pdc, '0', [location])
from master.dbo.auto_restore_job_parameters

exec dbo.automatic_database_restore
@before_date				= @before_date, 
@db_restore_name			= @db_restore_name,
@username					= @username,
@PDC_backup_path			= @pdc,
@SDC_backup_path			= @sdc,
@continue_after_file_number = 0,
@action						= 3
8

--01:45:07
--07:26:26
----------
--09:11:33
