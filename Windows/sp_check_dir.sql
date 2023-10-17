use master
go
if object_id('[dbo].[sp_check_dir]') is not null
begin
drop procedure [dbo].[sp_check_dir] 
end
go
create procedure [dbo].[sp_check_dir] (@path varchar(3000), @action int)
as
begin
declare @dir varchar(3000), @cd varchar(3000), @dir_cd varchar(3000)
declare @dir_R table (dir_is_exist int, dir varchar(3000))
declare dir_cursor cursor fast_forward
for
select value
from master.dbo.Separator(@path,'\')
where len(value) > 1
order by id

set nocount on

open dir_cursor
fetch next from dir_cursor into @dir
while @@FETCH_STATUS = 0
begin
create table #dir (output_text varchar(max))

set @cd = isnull(@cd+'\','')+@dir
set @dir_cd = 'xp_cmdshell ''dir cd "'+@cd+'"'''
insert into #dir
exec (@dir_cd)

insert into @dir_R 
select case when count(*) > 0 then 1 else 0 end dir_is_exist, @dir
from #dir
where output_text like '%<DIR>%'

drop table #dir

fetch next from dir_cursor into @dir
end
close dir_cursor 
deallocate dir_cursor 

if (select sum(dir_is_exist) from @dir_R) < (select max(id) from master.dbo.Separator(@path,'\') where len(value) > 1)
begin
set @dir_cd = 'xp_cmdshell ''mkdir "'+@path+'"'''
if @action = 1
begin
print(@dir_cd)
end
else 
if @action in (2,3)
begin
exec(@dir_cd)
end
end

set nocount off
end
