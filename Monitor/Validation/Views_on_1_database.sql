select 
id, view_id, view_name, v.create_date, v.modify_date
from (
select id, 
object_id(replace(convert(varbinary(100),replace(convert(varbinary(100),ltrim(rtrim(view_name))),0x0900,N'')),0x0D00,N'')) view_id, 
replace(convert(varbinary(100),replace(convert(varbinary(100),ltrim(rtrim(view_name))),0x0900,N'')),0x0D00,N'') view_name
--,convert(varbinary(100),ltrim(rtrim(view_name))) v
from (
select id, 
ltrim(rtrim(substring(alter_view+' ',1,charindex(' ',alter_view+' ')))) view_name, 
alter_view, syntax
from (
select top 100 percent id, ltrim(rtrim(substring(ltrim(rtrim(syntax)),charindex(' VIEW ',ltrim(rtrim(syntax)))+6,len(syntax)))) alter_view, syntax
from master.dbo.validation_syntax
where syntax like '%ALTER VIEW%'
order by id)a)b)c inner join sys.views v
on c.view_id = v.object_id
order by v.modify_date desc

