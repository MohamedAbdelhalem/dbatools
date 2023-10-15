--declare @table_name varchar(500) = 'FBNK_BAB_VISA_CRD_ISSUE'
declare @table_name varchar(500) = 'F_JOB_LIST_45'--,F_JOB_LIST_164'
exec sp_table_indexes @table_name

select object_name(c.object_id) table_name, c.name column_name, tp.name +
case when tp.name in ('varchar','nvarchar','char','nchar','varbinary','binary') then '('+cast(c.max_length as varchar(20))+')' else '' end data_type, 
substring(cc.definition,2,charindex('(',cc.definition,2)-2) [compute_function],
isnull(cc.is_computed,0) is_computed, isnull(cc.is_persisted,0) is_persisted, index_name
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
inner join sys.types tp
on c.user_type_id = tp.user_type_id
left outer join (
select i.object_id, i.name index_name, ic.column_id
from sys.indexes i inner join sys.index_columns ic
on i.object_id = ic.object_id
and i.index_id = ic.index_id) i
on i.object_id = t.object_id
and i.column_id = c.column_id
left outer join sys.computed_columns cc
on cc.object_id = c.object_id
and cc.column_id = c.column_id
where t.name = @table_name



--declare @ignored_volumes varchar(100) = 'F:\, H:\'
--declare @v_ignored_volumes varchar(100)
--select @v_ignored_volumes = isnull(@v_ignored_volumes+',','') + 
--''''+''''+ltrim(rtrim(value))+''''+''''
--from master.dbo.Separator(@ignored_volumes,',')

--select @v_ignored_volumes
