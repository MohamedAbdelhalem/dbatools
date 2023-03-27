declare 
@location nvarchar(1000) = '\\npci1.d1fs.albilad.com\SQLNativeBackup\',
@xp_cmdshell nvarchar(2000)

set nocount on
set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@location+''''
declare @root_folder table (output_text nvarchar(max), level_id int, root_folder nvarchar(1000), index inx_level_id (level_id))
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 1, root_folder = @location where level_id is null

declare @id int, @folder_name nvarchar(1000), @root_folder_name nvarchar(3000)
declare level_1_cursor cursor fast_forward
for
select row_number() over(order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, root_folder
from @root_folder
where output_text like '%<DIR>%')a
union
select 'file' [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, root_folder
from @root_folder
where output_text like '%.bak%' and output_text not like '%<DIR>%')b)c
where name not in ('.','..')
and type = '<DIR>'
order by id

open level_1_cursor
fetch next from level_1_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@location+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 2, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_1_cursor into @id, @folder_name, @root_folder_name
end
close level_1_cursor
deallocate level_1_cursor


declare level_2_cursor cursor fast_forward
for
select row_number() over(partition by root_folder order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%'
and level_id > 1)a)b
order by root_folder, id


open level_2_cursor
fetch next from level_2_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@root_folder_name+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 3, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_2_cursor into @id, @folder_name, @root_folder_name
end
close level_2_cursor
deallocate level_2_cursor


declare level_3_cursor cursor fast_forward
for
select row_number() over(partition by root_folder order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%'
and level_id > 2)a)b
order by root_folder, id

open level_3_cursor
fetch next from level_3_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@root_folder_name+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 4, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_3_cursor into @id, @folder_name, @root_folder_name
end
close level_3_cursor
deallocate level_3_cursor

declare level_4_cursor cursor fast_forward
for
select row_number() over(partition by root_folder order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%'
and level_id > 3)a)b
order by root_folder, id

open level_4_cursor
fetch next from level_4_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@root_folder_name+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 5, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_4_cursor into @id, @folder_name, @root_folder_name
end
close level_4_cursor
deallocate level_4_cursor

declare level_5_cursor cursor fast_forward
for
select row_number() over(partition by root_folder order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%'
and level_id > 4)a)b
order by root_folder, id

open level_5_cursor
fetch next from level_5_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@root_folder_name+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 6, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_5_cursor into @id, @folder_name, @root_folder_name
end
close level_5_cursor
deallocate level_5_cursor

declare level_6_cursor cursor fast_forward
for
select row_number() over(partition by root_folder order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%'
and level_id > 5)a)b
order by root_folder, id

open level_6_cursor
fetch next from level_6_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@root_folder_name+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 7, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_6_cursor into @id, @folder_name, @root_folder_name
end
close level_6_cursor
deallocate level_6_cursor

declare level_7_cursor cursor fast_forward
for
select row_number() over(partition by root_folder order by name) id, name, root_folder
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%'
and level_id > 6)a)b
order by root_folder, id

open level_7_cursor
fetch next from level_7_cursor into @id, @folder_name, @root_folder_name
while @@FETCH_STATUS = 0
begin

set @xp_cmdshell = 'xp_cmdshell '+''''+'dir cd '+@root_folder_name+'\'+@folder_name+''''
insert into @root_folder (output_text)
exec(@xp_cmdshell)

update @root_folder set level_id = 8, root_folder = @root_folder_name+'\'+@folder_name where level_id is null

fetch next from level_7_cursor into @id, @folder_name, @root_folder_name
end
close level_7_cursor
deallocate level_7_cursor

--truncate table [dbo].[PDC_TO_SDC_Folders]
insert into [dbo].[PDC_TO_SDC_Folders] (part_id, path_folder)
select row_number() over(partition by root_folder order by name) id, root_folder+'\'+name [path]
from (
select ltrim(rtrim(substring(output_text, 1, charindex('>',output_text)))) [type], ltrim(rtrim(substring(output_text, charindex(' ',output_text), len(output_text)))) [name], level_id, root_folder
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text, level_id, root_folder
from @root_folder
where output_text like '%M %'
and (output_text not like '%<DIR>%.%' and output_text not like '%<DIR>%..%')
and output_text like '%<DIR>%')a)b
order by root_folder, id

set nocount off
go

--select * from [dbo].[PDC_TO_SDC_Folders]