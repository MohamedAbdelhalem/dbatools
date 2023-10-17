--model lock 
select db_name(dbid) database_name, 'kill '+cast(spid as varchar(10)) kill_script
from sys.sysprocesses 
where db_name(dbid) = 'model'
