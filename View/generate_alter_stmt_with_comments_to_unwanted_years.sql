use Data_Hub_T24_history
go
declare @database_name varchar(500) = 'Data_Hub_T24_history_2023'
declare @years varchar(1000) = '2014,2017,2019,2021,2022'
declare @group_year_table table (id int, group_year varchar(10))
declare 
@group_years int,
@group_year_1 varchar(5),
@group_year_2 varchar(5),
@group_year_3 varchar(5),
@group_year_4 varchar(5),
@group_year_1_like varchar(100),
@group_year_2_like varchar(100),
@group_year_3_like varchar(100),
@group_year_4_like varchar(100)

select @group_years = count(distinct left(value,3))
from master.dbo.Separator(@years,',')

insert into @group_year_table
select ROW_NUMBER() over(order by group_year), group_year
from (
select distinct left(value,3) group_year
from master.dbo.Separator(@years,','))a

declare @views table (id int identity(1,1), name varchar(255), line_id int, alter_statement_with_comment varchar(max), undo_before_alter varchar(max))
declare @object_id bigint
declare i cursor fast_forward
for
select distinct object_id 
from sys.all_sql_modules 
where definition like '%'+@database_name+'%'

open i
fetch next from i into @object_id
while @@FETCH_STATUS = 0
begin

if @group_years = 1
begin

set @group_year_1_like = null

select @group_year_1 = group_year 
from @group_year_table 
where id = 1

select @group_year_1_like = isnull(@group_year_1_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_1

insert into @views (name, line_id, alter_statement_with_comment, undo_before_alter)
select v.name, ss.id, case 
when (ss.value not like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%') and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %' then replace(ss.value,'CREATE','ALTER')
when (ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%') and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %SELECT %' then replace(replace(ss.value,'CREATE','ALTER'),' AS ',' AS-- ') 
when (ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%') and (ss.value not like '%CREATE %VIEW %' ) and ss.value not like '% AS %SELECT %' then '--'+ss.value
--when ss.value like '%'+reverse(SUBSTRING(reverse(@database_name),charindex('_',reverse(@database_name)),LEN(reverse(@database_name))))+'_Max%' then ''+ss.value
else 
ss.value end before_change,
case when ss.value like '%CREATE %VIEW %' then replace(ss.value,'CREATE','ALTER') else ss.value end original
from sys.all_sql_modules s inner join sys.views v
on s.object_id = v.object_id
cross apply master.dbo.Separator(s.definition, CHAR(10)) ss
where v.object_id = @object_id
order by v.name, ss.id

end
else
if @group_years = 2
begin

set @group_year_1_like = null
set @group_year_2_like = null

select @group_year_1 = group_year 
from @group_year_table 
where id = 1

select @group_year_1_like = isnull(@group_year_1_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_1

select @group_year_2 = group_year 
from @group_year_table 
where id = 2

select @group_year_2_like = isnull(@group_year_2_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_2

insert into @views (name, line_id, alter_statement_with_comment, undo_before_alter)
select v.name, ss.id, case 
when (ss.value not like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' and ss.value not like '%'+@group_year_2+'['+@group_year_2_like+']%') and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %' then replace(ss.value,'CREATE','ALTER')
when (
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' or 
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_2+'['+@group_year_2_like+']%'
) 
and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %SELECT %' then replace(replace(ss.value,'CREATE','ALTER'),' AS ',' AS-- ') 
when (
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' or 
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_2+'['+@group_year_2_like+']%'
) 
and (ss.value not like '%CREATE %VIEW %') and ss.value not like '% AS %SELECT %' then '--'+ss.value
--when ss.value like '%'+reverse(SUBSTRING(reverse(@database_name),charindex('_',reverse(@database_name)),LEN(reverse(@database_name))))+'_Max%' then '--'+ss.value
else 
ss.value end before_change,
case when ss.value like '%CREATE %VIEW %' then replace(ss.value,'CREATE','ALTER') else ss.value end original
from sys.all_sql_modules s inner join sys.views v
on s.object_id = v.object_id
cross apply master.dbo.Separator(s.definition, CHAR(10)) ss
where v.object_id = @object_id
order by v.name, ss.id

end
else
if @group_years = 3
begin

set @group_year_1_like = null
set @group_year_2_like = null
set @group_year_3_like = null

select @group_year_1 = group_year 
from @group_year_table 
where id = 1

select @group_year_1_like = isnull(@group_year_1_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_1

select @group_year_2 = group_year 
from @group_year_table 
where id = 2

select @group_year_2_like = isnull(@group_year_2_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_2

select @group_year_3 = group_year 
from @group_year_table 
where id = 3

select @group_year_3_like = isnull(@group_year_3_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_3

insert into @views (name, line_id, alter_statement_with_comment, undo_before_alter)
select v.name, ss.id, case 
when (ss.value not like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' and ss.value not like '%'+@group_year_2+'['+@group_year_2_like+']%') and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %' then replace(ss.value,'CREATE','ALTER')
when (
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' or 
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_2+'['+@group_year_2_like+']%' or
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_3+'['+@group_year_3_like+']%'
) 
and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %SELECT %' then replace(replace(ss.value,'CREATE','ALTER'),' AS ',' AS-- ') 
when (
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' or 
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_2+'['+@group_year_2_like+']%' or
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_3+'['+@group_year_3_like+']%' 
) and (ss.value not like '%CREATE %VIEW %') and ss.value not like '% AS %SELECT %' then '--'+ss.value
--when ss.value like '%'+reverse(SUBSTRING(reverse(@database_name),charindex('_',reverse(@database_name)),LEN(reverse(@database_name))))+'_Max%' then '--'+ss.value
else 
ss.value end before_change,
case when ss.value like '%CREATE %VIEW %' then replace(ss.value,'CREATE','ALTER') else ss.value end original
from sys.all_sql_modules s inner join sys.views v
on s.object_id = v.object_id
cross apply master.dbo.Separator(s.definition, CHAR(10)) ss
where v.object_id = @object_id
order by v.name, ss.id

end
else
if @group_years = 4
begin

set @group_year_1_like = null
set @group_year_2_like = null
set @group_year_3_like = null
set @group_year_4_like = null

select @group_year_1 = group_year 
from @group_year_table 
where id = 1

select @group_year_1_like = isnull(@group_year_1_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_1

select @group_year_2 = group_year 
from @group_year_table 
where id = 2

select @group_year_2_like = isnull(@group_year_2_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_2

select @group_year_3 = group_year 
from @group_year_table 
where id = 3

select @group_year_3_like = isnull(@group_year_3_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_3

select @group_year_4 = group_year 
from @group_year_table 
where id = 4

select @group_year_4_like = isnull(@group_year_4_like,'')+right(value,1) 
from master.dbo.Separator(@years,',')
where LEFT(value,3) = @group_year_4

insert into @views (name, line_id, alter_statement_with_comment, undo_before_alter)
select v.name, ss.id, case 
when (ss.value not like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' and ss.value not like '%'+@group_year_2+'['+@group_year_2_like+']%') and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %' then replace(ss.value,'CREATE','ALTER')
when (
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' or 
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_2+'['+@group_year_2_like+']%' or
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_3+'['+@group_year_3_like+']%' or
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_4+'['+@group_year_4_like+']%'
) 
and ss.value like '%CREATE %VIEW %' and ss.value like '% AS %SELECT %' then replace(replace(ss.value,'CREATE','ALTER'),' AS ',' AS-- ') 
when (
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_1+'['+@group_year_1_like+']%' or 
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_2+'['+@group_year_2_like+']%' or
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_3+'['+@group_year_3_like+']%' or
ss.value like '%'+reverse(substring(reverse(@database_name),charindex('_',reverse(@database_name)),len(@database_name)))+@group_year_4+'['+@group_year_4_like+']%' 
) and (ss.value not like '%CREATE %VIEW %') and ss.value not like '% AS %SELECT %' then '--'+ss.value
--when ss.value like '%'+reverse(SUBSTRING(reverse(@database_name),charindex('_',reverse(@database_name)),LEN(reverse(@database_name))))+'_Max%' then '--'+ss.value
else 
ss.value end before_change,
case when ss.value like '%CREATE %VIEW %' then replace(ss.value,'CREATE','ALTER') else ss.value end original
from sys.all_sql_modules s inner join sys.views v
on s.object_id = v.object_id
cross apply master.dbo.Separator(s.definition, CHAR(10)) ss
where v.object_id = @object_id
order by v.name, ss.id

end

insert into @views values ('go',1,'go','go')

fetch next from i into @object_id
end
close i
deallocate i

select * 
from @views 
--where name = 'F_BAB_H_REL_CON_PARTY' 
order by id

