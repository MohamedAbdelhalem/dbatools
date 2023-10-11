select 
isnull(a.database_id,'') database_id, 
isnull(a.database_name,'') database_name, 
master.dbo.numberSize(b.size,'k') size, 
isnull(file_growth,'') file_growth,
master.dbo.numberSize(b.used,'k') used,
master.dbo.numberSize(b.free,'k') free,
isnull(a.name,'') logical_name, isnull(a.physical_name,'') physical_name
from (


select 
sum(cast(size as float)*8) size, 
sum(cast(FILEPROPERTY(name, 'spaceused') as float)) used,
sum((cast(size as float)*8) - (cast(FILEPROPERTY(name, 'spaceused') as float))) free,
name, grouping(name) g
from sys.master_files
where database_id = db_id()
and file_id != 2
group by name with rollup)b left outer join (
select database_id,
db_name(database_id) database_name, 
master.dbo.numberSize(growth*8,'k') file_growth,
name, physical_name
from sys.master_files
where database_id = db_id()
and file_id != 2



)a
on b.name = a.name