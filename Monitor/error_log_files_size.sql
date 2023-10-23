declare @error_log_files table (fileid int, date datetime, log_file_size_byte bigint)

insert into @error_log_files
exec master.dbo.sp_enumerrorlogs

select fileid int, date , master.dbo.numbersize(log_file_size_byte,'b') error_log_file_size
from @error_log_files
order by fileid
