declare 
@files int, 
@loop int = 0
select @files = count(*)
from sys.master_files
where database_id = 2
and file_id != 2

while @loop < 10 - @files
begin

select path, 'tempdb_data_'+cast(@files + @loop + 1 as varchar(100))+'.ndf'
from (
select reverse(substring(reverse(physical_name), charindex('\',reverse(physical_name))+1, len(reverse(physical_name)))) path, max_file_id , 
reverse(substring(reverse(physical_name), 1, charindex('\',reverse(physical_name))-1)) file_name
from (
select file_id, physical_name,MAX(file_id) over() max_file_id  
from sys.master_files
where database_id = 2
and file_id != 2)a
where file_id = max_file_id)b

set @loop += 1
end
