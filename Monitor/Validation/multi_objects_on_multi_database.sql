use master
go
--master.dbo.validation_syntax_15
declare @search varchar(100) = 'CREATE VIEW'
declare @validation table (id int identity(1,1), operation nvarchar(100), object_type nvarchar(100), [object_name] nvarchar(500), [database_name] nvarchar(500), exist int, last_modify_date datetime)

declare 
@operation		nvarchar(100), 
@object_type	nvarchar(100), 
@object_name	nvarchar(500), 
@database_name	nvarchar(500),
@sql			nvarchar(max),
@exist			int,
@last_mDate		datetime

declare cursor_validate cursor
for
select
Operation, object_type, 
case when has_db = 1 then master.dbo.vertical_array([object_name],'.',3) else [object_name] end [object_name],
case when has_db = 0 and d.id between e.from_id and case when e.new_db_id = 0 then e.from_id * 4 else e.new_db_id end then e.database_name else substring([object_name],1,charindex('.',[object_name])-1) end database_name
from (
select 
id, Operation, object_type, [object_id], [object_name], case when charindex('.',[object_name],charindex('.',[object_name])+1) > 0 then 1 else 0 end has_db
from (
select id, Operation,object_type,
object_id(replace(convert(varbinary(400),replace(convert(varbinary(100),ltrim(rtrim(view_name))),0x0900,N'')),0x0D00,N'')) [object_id], 
replace(convert(varbinary(400),replace(convert(varbinary(400),ltrim(rtrim(view_name))),0x0900,N'')),0x0D00,N'') [object_name]
--,convert(varbinary(100),ltrim(rtrim(view_name))) v
from (
select id, Operation,object_type,
ltrim(rtrim(substring(alter_view+' ',1,charindex(' ',alter_view+' ')))) view_name, 
alter_view
from (
select top 100 percent 
id, 
substring(ltrim(rtrim(syntax)),1, charindex(' ',ltrim(rtrim(syntax)))-1) Operation, 
case 
when syntax like '%View%' then 'VIEW'
when syntax like '%table%' then 'TABLE'
when syntax like '%function%' then 'FUNCTION'
when syntax like '%procedure%' then 'PROCEDURE'
end object_type,
ltrim(rtrim(substring(ltrim(rtrim(syntax)),charindex(case 
when syntax like '%View%' then 'VIEW'
when syntax like '%table%' then 'TABLE'
when syntax like '%function%' then 'FUNCTION'
when syntax like '%procedure%' then 'PROCEDURE'
end,ltrim(rtrim(syntax))) + case 
when syntax like '%View%' then 4
when syntax like '%table%' then 5
when syntax like '%function%' then 8
when syntax like '%procedure%' then 9
end,len(syntax)))) alter_view, 
syntax
from master.dbo.validation_syntax_15
where syntax like '%'+@search+'%'
order by id)a)b)c)d
inner join (select top 100 percent
ltrim(rtrim(substring(ltrim(rtrim(syntax)),charindex(' ',ltrim(rtrim(syntax)))+1,len(ltrim(rtrim(syntax)))))) database_name, id from_id, 
case when lag(id,1,1) over(order by id desc) - 1 = 0 then (select count(*) from master.dbo.validation_syntax_15) else lag(id,1,1) over(order by id desc) - 1 end new_db_id
from master.dbo.validation_syntax_15
where syntax like '%Use %'
order by id) e
on d.id between e.from_id and case when e.new_db_id = 0 then e.from_id * 4 else e.new_db_id end
order by id

open cursor_validate
fetch next from cursor_validate into @operation, @object_type, @object_name, @database_name
while @@FETCH_STATUS = 0
begin

set @sql = 'USE '+@database_name+'
select @output = case when object_id('+''''+@object_name+''''+') > 0 then 1 else 0 end
if @output = 1 and '+''''+@object_type+''''+' = ''VIEW''
begin
select @last_modify_date = v.modify_date
from sys.views v
where object_id = object_id('+''''+@object_name+''''+')
end'
--print(@sql)

exec sp_executesql @sql, N'@output int output, @last_modify_date datetime output', @exist output, @last_mDate output

insert into @validation (operation,object_type, object_name, database_name, exist, last_modify_date) 
values (@operation, @object_type, @object_name, @database_name, @exist, @last_mDate)

fetch next from cursor_validate into @operation, @object_type, @object_name, @database_name
end
close cursor_validate
deallocate cursor_validate

select row_count, exist, case when exist = 0 then cast(row_count as float) / cast(sum(row_count) over() as float) * 100.0 end percent_complete
from (
select count(*) row_count, exist
from @validation
group by exist)a

select * from @validation
order by exist, last_modify_date desc
