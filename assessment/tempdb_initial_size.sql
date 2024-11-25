select 
case when size < 1048576 then 'alter database ['+db_name(database_id)+'] modify file (name='+''''+name+''''+', size = 8GB)' else 'nothing' end recommended_intial_size_8GB, 
name, master.dbo.numbersize(size*8.0,'k') size
from sys.master_files 
where database_id = 2
and type = 0
