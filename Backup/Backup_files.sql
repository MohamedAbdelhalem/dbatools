set nocount on
--truncate table backup_files
declare @folder_content table (output_text nvarchar(max), id int)
declare @loc nvarchar(2000), @id int
declare @xp_cmdshell nvarchar(2000)
declare i cursor fast_forward
for
select id, path_folder 
from [dbo].[PDC_TO_SDC_Folders]
order by id 

open i
fetch next from i into @id, @loc
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@loc+''''
print(@xp_cmdshell)
insert into @folder_content (output_text)
exec(@xp_cmdshell)

update @folder_content set id = @id where id is null

insert into [dbo].[PDC_TO_SDC_Files] (backup_file_name , [location])
select [name], [location]
from (
select [name], @loc [location], id
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], id
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, id
from @folder_content
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text not like '%<DIR>%')a)b
where (name like '%.bak' or name like '%.trn')
)c
where id = @id

fetch next from i into @id, @loc
end
close i
deallocate i
set nocount off

--select * from [dbo].[PDC_TO_SDC_Files]
--truncate table backup_files
