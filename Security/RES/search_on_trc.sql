declare @log_path varchar(1000), @xp_cmdshell varchar(max), @log varchar(1000)
declare @log_table table (output_text varchar(max))
select @log_path = 
substring(reverse(substring(reverse(value_data), charindex('\',reverse(value_data)), len(value_data))),3,len(value_data))
from (
select cast(value_data as varchar(max)) value_data
from sys.dm_server_registry r cross apply (select left(cast(value_data as varchar(20)),2) [ver] 
from sys.dm_server_registry 
where cast(value_name as varchar(max)) = 'CurrentVersion') v
where registry_key = 'HKLM\Software\Microsoft\Microsoft SQL Server\MSSQL'+v.ver+'.MSSQLSERVER\MSSQLServer\Parameters'
and cast(value_data as varchar(max)) like '-e%'
)a
set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd "'+@log_path+'"'''
insert into @log_table 
exec(@xp_cmdshell)

declare trc_cursor cursor fast_forward
for
select max(reverse(substring(reverse(ltrim(rtrim(output_text))),1, charindex(' ',reverse(ltrim(rtrim(output_text))))-1))) trc
from @log_table
where output_text like '%.trc%'
order by trc

open trc_cursor
fetch next from trc_cursor into @log
while @@FETCH_STATUS = 0
begin

set @log = @log_path+@log
print(@log)

SELECT StartTime, HostName, ApplicationName, LoginName, TextDAta
FROM sys.fn_trace_gettable(@log,DEFAULT)   
WHERE EventClass = 116 
AND TextData LIKE '%DETACH%'

fetch next from trc_cursor into @log
end
close trc_cursor
deallocate trc_cursor
