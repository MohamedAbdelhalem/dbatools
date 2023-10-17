Create VIEW [dbo].[foreign_key_view]
as
select object_name(fk.constid) foreign_key, object_name(fk.id) table_name, col.name foreign_key_column_name, object_name(ref.rkeyid) reference_table_name
from sys.sysconstraints fk inner join sys.columns col
on fk.colid = col.column_id
and fk.id = col.object_id
inner join sys.sysreferences ref
on ref.constid = fk.constid
GO
Create VIEW [dbo].[primary_foreign_keys]
as
select pk.name primary_key, object_name(ref.rkeyid) primary_key_table, object_name(ref.constid) foreign_key, object_name(ref.fkeyid) foreign_key_table 
from sys.sysreferences ref inner join sys.key_constraints pk
on object_name(rkeyid) = object_name(parent_object_id) 
GO
Create VIEW [dbo].[primary_key_view]
as
select object_name(constid) primary_key, object_name(id) table_name, col.name primary_key_column_name
from sys.sysconstraints cons inner join sys.columns col
on col.object_id = cons.id
and cons.colid = col.column_id-1
inner join sys.objects obj
on constid = obj.object_id
where obj.type = 'PK'
GO
Create VIEW [dbo].[foreign_key]
as
select fk.table_name, fk.foreign_key, fk.foreign_key_column_name, fk.reference_table_name, pk.primary_key_column_name
from foreign_key_view fk inner join primary_foreign_keys pfk
on fk.foreign_key = pfk.foreign_key
inner join primary_key_view pk
on pk.primary_key = pfk.primary_key
GO
Create VIEW [dbo].[Foreign_Key_Create_Script]
as
select 'Alter Table '+table_name+' Add Constraint '+foreign_key+' Foreign Key ('+foreign_key_column_name+') References '+reference_table_name+' ('+primary_key_column_name+')' Foreign_Key_Text, *
from foreign_key
GO
Create VIEW [dbo].[Foreign_Key_Drop_Script]
as
select 'Alter Table '+table_name+' Drop Constraint '+foreign_key Foreign_Key_Text, *
from foreign_key