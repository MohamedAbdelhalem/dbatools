alter Procedure [dbo].[sp_change_filegroup]
(@table_name_with_schema varchar(500), @new_filegroup varchar(100))
as
begin
declare 
@drop_constaint_pk_index varchar(3000),
@recreate_pk_on_ofg varchar(3000)

select 
@drop_constaint_pk_index = 'ALTER TABLE ['+[schema]+'].['+table_name+'] DROP CONSTRAINT ['+constraint_name+']' ,
@recreate_pk_on_ofg = 'ALTER TABLE ['+[schema]+'].['+table_name+'] ADD  CONSTRAINT ['+constraint_name+'] PRIMARY KEY CLUSTERED ('+keys+') ON ['+@new_filegroup+']' 
from (
select object_id, constraint_name, [schema], table_name, type, index_name, type_desc, 
         '['+[1]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end +
isnull(', ['+[2]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[3]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[4]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[5]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[6]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[7]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[8]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[9]+'] ' +case is_desc when 0 then 'ASC' else 'DESC' end,'')+
isnull(', ['+[10]+'] '+case is_desc when 0 then 'ASC' else 'DESC' end,'') keys
from (
select t.object_id, kc.name constraint_name, schema_name(t.schema_id) [schema], t.name table_name, kc.type, i.name index_name, i.type_desc, ik.keyno, c.name column_name, ic.is_descending_key is_desc
from sys.tables t inner join sys.indexes i 
on t.object_id = i.object_id
inner join sys.key_constraints kc
on t.object_id = kc.parent_object_id
inner join sys.sysindexkeys ik
on t.object_id = ik.id
and i.index_id = ik.indid
inner join sys.columns c
on t.object_id = c.object_id
and ik.colid = c.column_id
inner join sys.index_columns ic
on i.index_id = ic.index_id
and i.object_id = ic.object_id
and ik.colid = ic.column_id)a
pivot (max(column_name) for keyno in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10]))p)b
where [object_id] = object_id(@table_name_with_schema)

exec(@drop_constaint_pk_index)
exec(@recreate_pk_on_ofg)

end



--exec [dbo].[sp_change_filegroup]
--@table_name_with_schema = '[dbo].[F_DE_O_HANDOFF_ARC]', 
--@new_filegroup = 'DATAFG2'

