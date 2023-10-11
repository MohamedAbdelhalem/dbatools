use master
go
-- first create a new or use an exist linked server.
-- [10.4.0.41].master.sys.master_files

declare @show int = 1, --1 = sorted by databases, 2 = sorted by drivers  
@letter char(1)
declare @table table ([filename] varchar(2000), [file] varchar(1000))
declare letter cursor
for
select distinct left(physical_name, 1)
from sys.master_files

open letter
fetch next from letter into @letter
while @@FETCH_STATUS = 0
begin

insert into @table
select physical_name, reverse(substring(reverse(physical_name),1, charindex('\',reverse(physical_name))-1)) 
from sys.master_files 
where reverse(substring(reverse(physical_name),1, charindex('\',reverse(physical_name))-1)) in (
select reverse(substring(reverse(physical_name),1, charindex('\',reverse(physical_name))-1)) files
from sys.master_files
where left(physical_name, 1) = @letter
except
select reverse(substring(reverse(physical_name),1, charindex('\',reverse(physical_name))-1)) files
from [10.4.0.41].master.sys.master_files
where left(physical_name, 1) = @letter)

fetch next from letter into @letter
end
close letter
deallocate letter

if @show = 1
begin
select dense_rank() over(order by db.name) database_id, 
db.name database_name, [filename], mf.physical_name mismatch_with_source_db
from @table t inner join [10.4.0.41].master.sys.master_files mf
on t.[file] = reverse(substring(reverse(mf.physical_name),1, charindex('\',reverse(mf.physical_name))-1))
inner join [10.4.0.41].master.sys.databases db
on mf.database_id = db.database_id
where mf.database_id > 4
end
else
if @show = 2
begin
select dense_rank() over(order by left([filename], 1)) drive_id, left([filename], 1) driveLetter,
db.name database_name, [filename], mf.physical_name mismatch_with_source_db
from @table t inner join [10.4.0.41].master.sys.master_files mf
on t.[file] = reverse(substring(reverse(mf.physical_name),1, charindex('\',reverse(mf.physical_name))-1))
inner join [10.4.0.41].master.sys.databases db
on mf.database_id = db.database_id
where mf.database_id > 4
order by left([filename], 1)
end

select [filename] Orphan_not_in_the_source
from @table
except
select [filename]
from @table t inner join [10.4.0.41].master.sys.master_files mf
on t.[file] = reverse(substring(reverse(mf.physical_name),1, charindex('\',reverse(mf.physical_name))-1))

