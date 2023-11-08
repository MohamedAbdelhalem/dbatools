select t.object_id , v.name, o.name, o.type_desc 
from sys.sql_expression_dependencies d inner join sys.views v
on d.referencing_id = v.object_id
inner join sys.objects o
on o.object_id = d.referenced_id
inner join sys.tables t
on t.object_id = d.referenced_id
where v.name = 'JV_FOMS_PM_DLY_POSN_CLASS'
order by v.name



select count(*), v.name 
from sys.sql_expression_dependencies d inner join sys.views v
on d.referencing_id = v.object_id
inner join sys.objects o
on o.object_id = d.referenced_id
inner join sys.tables t
on t.object_id = d.referenced_id
group by v.name
having count(*) > 1
order by count(*) desc

