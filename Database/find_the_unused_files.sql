use master
go

declare @DriveLetter char(1) = 'E'

select distinct reverse(substring(reverse(physical_name), charindex('\',reverse(physical_name)), len(physical_name)))
from sys.master_files
where left(physical_name,1) = @DriveLetter

declare @directory varchar(2000), @sql varchar(max)
declare @table table (output_text varchar(max))
declare @files table ([file_name] varchar(max), size varchar(100), last_modify_date varchar(50))
declare dir cursor fast_forward
for
select distinct reverse(substring(reverse(physical_name), charindex('\',reverse(physical_name)), len(physical_name)))
from sys.master_files
where left(physical_name,1) = @DriveLetter

open dir
fetch next from dir into @directory
while @@FETCH_STATUS = 0
begin

set @sql = 'xp_cmdshell ''dir cd "'+@directory+'"''' 
insert into @table
exec(@sql)

insert into @files
select @directory+[file], size, last_modify_date
from (
select 
ltrim(rtrim(substring(output_text, charindex(' ' ,output_text)+1, len(output_text)))) [file],
substring(output_text, 1, charindex(' ' ,output_text)-1) size, last_modify_date
from (
select 
ltrim(rtrim(substring(output_text, charindex('m ',output_text)+1, len(output_text)))) output_text,
ltrim(rtrim(substring(output_text, 1, charindex('m ',output_text)-2))) last_modify_date
from @table
where output_text like '%M %'
and output_text not like '%<DIR>%')a)b

delete @table 

fetch next from dir into @directory
end
close dir
deallocate dir

select [file_name],last_modify_date,
master.dbo.NumberSize(replace(size,',',''),'b') size, 
master.dbo.NumberSize(sum(cast(replace(size,',','') as float)/1024/1024) over(),'M') total_files_size
from @files
where file_name not in (select physical_name from sys.master_files where left(physical_name,1) = @DriveLetter)

exec database_size @report = 3, @volumes = @driveletter
exec database_size @report = 1, @volumes = @driveletter
