--search on funtions
select sp.id, master.dbo.vertical_array(sp.value,'''',2) xml_attribute, 
master.dbo.vertical_array(sp.value,'''',4) data_type, 
sp.value, o.name function_name
from sys.all_sql_modules s inner join sys.objects o
on s.object_id = o.object_id
and o.type = 'FN'
cross apply master.dbo.Separator(s.definition,char(10))sp
where sp.value like 'RETURN %'
and sp.value like '%value(''(/row/c%m%'
order by s.object_id, sp.id

