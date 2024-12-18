declare
@tabs varchar(max) = 'F_OS_XML_CACHE, F_OS_TOKEN'

set nocount on
declare @tables table ([object_id] bigint)
insert into @tables 
select object_id(LTRIM(RTRIM(value))) from master.dbo.Separator(@tabs,',')

declare @rebuild table (id int identity(1,1), script varchar(4000))
insert into @rebuild (script)
select maintenance_script
from (
select '['+schema_name(schema_id)+'].['+Table_Name+']' Table_Name, Index_Name,index_id,
case 
when Avg_Frag_PCT between 15 and 30 then 
case when index_id > 0 then 'ALTER INDEX ['+Index_Name+'] ON ['+schema_name(schema_id)+'].['+Table_Name+'] REORGANIZE WITH ( LOB_COMPACTION = ON )' else null end
when Avg_Frag_PCT > 30 then 
case 
when index_id = 0 then 'ALTER TABLE ['+Table_Name+'] REBUILD PARTITION = ALL WITH (ONLINE = '+case ver when 'Enterprise' then 'ON' when 'Developer' then 'ON' else 'OFF' end+', MAXDOP = 1)'
when index_id > 0 then 'ALTER INDEX ['+Index_Name+'] ON ['+schema_name(schema_id)+'].['+Table_Name+'] REBUILD PARTITION = ALL WITH (ONLINE = '+case ver when 'Enterprise' then 'ON' when 'Developer' then 'ON' else 'OFF' end+', MAXDOP = 1)'
end
end Maintenance_Script,
case 
when Avg_Frag_PCT between 15 and 30 then 'Reorganize'
when Avg_Frag_PCT > 30 then 'Rebuild'
end maintenance_Type, avg_frag_pct, page_count, master.dbo.format(Rows,-1) Rows
from (
select 
t.schema_id, max(page_count) page_count, Table_Name, Index_Name, max(Avg_Frag_PCT) Avg_Frag_PCT,index_id,
substring(cast(serverproperty('edition') as varchar(20)) , 1, charindex(' ', cast(serverproperty('edition') as varchar(20)))-1) ver
from (
select 
i.object_id, object_name(i.object_id) Table_Name, i.index_id, isnull(i.name, 'HEAP Table') Index_Name, ips.Index_Type_Desc, 
Alloc_Unit_Type_Desc, ips.Page_Count, 
case index_level when 0 then 'Leaf Level (data)' else 'Non-Leaf Level no '+ltrim(rtrim(cast(index_level as char)))+' (Index data)' end Index_Level, 
round(avg_fragmentation_in_percent, 2) Avg_Frag_PCT, 
round(avg_page_space_used_in_percent,2) Avg_Page_Space_Used_in_Percent, Fragment_Count, Forwarded_Record_Count
from sys.indexes i cross apply sys.dm_db_index_physical_stats(db_id(),i.object_id, i.index_id,null,'detailed') ips)a inner join sys.tables t
on a.object_id = t.object_id
where t.object_id in (select [object_id] from @tables)
group by Table_Name, Index_Name, t.schema_id, index_id
)b
inner join (select MAX(rows) Rows, [object_id] from sys.partitions where object_id in (select [object_id] from @tables) group by [object_id]) p
on object_id('['+schema_name(schema_id)+'].['+Table_Name+']') = p.object_id)c
where maintenance_script is not null
order by table_name, index_id, avg_frag_pct desc

declare @sql varchar(4000)
declare rebuild_cursor cursor fast_forward
for
select script
from @rebuild
order by id

open rebuild_cursor
fetch next from rebuild_cursor into @sql
while @@FETCH_STATUS = 0
begin

--exec(@sql)
print(@sql)

fetch next from rebuild_cursor into @sql
end
close rebuild_cursor
deallocate rebuild_cursor

set nocount off
