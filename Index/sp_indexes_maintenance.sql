CREATE Procedure [dbo].[sp_indexes_maintenance]
as
begin
declare @script varchar(max)
declare mainCursor Cursor fast_forward
for
Select Maintenance_Script
from (
select 
'['+schema_name(schema_id)+'].['+Table_Name+']' Table_Name, Index_Name,
case 
when Avg_Frag_PCT between 15 and 30 then 
'ALTER INDEX ['+Index_Name+'] ON ['+schema_name(schema_id)+'].['+Table_Name+'] REORGANIZE WITH ( LOB_COMPACTION = ON )
go'
when Avg_Frag_PCT > 30 then 
'ALTER INDEX ['+Index_Name+'] ON ['+schema_name(schema_id)+'].['+Table_Name+'] REBUILD PARTITION = ALL 
WITH (
SORT_IN_TEMPDB	= ON, 
ONLINE		= '+case ver when 'Enterprise' then 'ON' when 'Developer' then 'ON' else 'OFF' end+', 
MAXDOP		= 1)
go'
end Maintenance_Script,
case 
when Avg_Frag_PCT between 15 and 30 then 'Reorganize'
when Avg_Frag_PCT > 30 then 'Rebuild'
end maintenance_Type, avg_frag_pct
from (
select 
t.schema_id, Table_Name, Index_Name, max(Avg_Frag_PCT) Avg_Frag_PCT, substring(cast(serverproperty('edition') as varchar(20)) , 1, charindex(' ', cast(serverproperty('edition') as varchar(20)))-1) ver
from (
select 
i.object_id, object_name(i.object_id) Table_Name, isnull(i.name, 'HEAP Table') Index_Name, ips.Index_Type_Desc, 
Alloc_Unit_Type_Desc, ips.Page_Count, 
case index_level when 0 then 'Leaf Level (data)' else 'Non-Leaf Level no '+ltrim(rtrim(cast(index_level as char)))+' (Index data)' end Index_Level, 
round(avg_fragmentation_in_percent, 2) Avg_Frag_PCT, 
round(avg_page_space_used_in_percent,2) Avg_Page_Space_Used_in_Percent, Fragment_Count, Forwarded_Record_Count
from sys.indexes i cross apply sys.dm_db_index_physical_stats(db_id(),i.object_id, i.index_id,null,'detailed') ips)a inner join sys.tables t
on a.object_id = t.object_id
where page_count >= 1000
and avg_frag_pct >= 20
group by Table_Name, Index_Name, t.schema_id)b)c
order by avg_frag_pct desc

open mainCursor 
fetch next from mainCursor into @script
while @@FETCH_STATUS = 0
begin
exec @script
fetch next from mainCursor into @script
end
close mainCursor
deallocate mainCursor

end
GO