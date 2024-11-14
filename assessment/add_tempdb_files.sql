declare 
@required_files int = 12,
@location		varchar(1000) = 'default'

declare @table table (output_text varchar(max))

declare 
@size	varchar(100),
@grow	varchar(100),
@files	int, 
@loop	int = 0
select @files = count(*)
from sys.master_files
where database_id = 2
and file_id != 2

select 
@size = replace(master.dbo.numbersize(MAX(size)*8,'k'),' ',''), 
@grow = replace(master.dbo.numbersize(MAX(growth)*8,'k'),' ','')
from sys.master_files
where database_id = 2
and type = 0

while @loop < @required_files - @files
begin

insert into @table
select 'Alter Database tempdb add file (name = '+''''+'tempdb_data_'+cast(@files + @loop + 1 as varchar(100))+''''+', filename = '+''''+case when @location is null or @location in ('default','') then path else case when right(rtrim(@location),1) = '\' then @location else @location+'\' end end +'tempdb_data_'+cast(@files + @loop + 1 as varchar(100))+'.ndf'+''''+', size='+@size+', growth='+@grow+')'
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

select * from @table
