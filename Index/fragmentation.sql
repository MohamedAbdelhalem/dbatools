select 
t.schema_id, Table_Name, Index_Name, max(Avg_Frag_PCT) Avg_Frag_PCT, page_count
from (
select 
i.object_id, object_name(i.object_id) Table_Name, isnull(i.name, 'HEAP Table') Index_Name, ips.Index_Type_Desc, 
Alloc_Unit_Type_Desc, ips.Page_Count, 
case index_level when 0 then 'Leaf Level (data)' else 'Non-Leaf Level no '+ltrim(rtrim(cast(index_level as char)))+' (Index data)' end Index_Level, 
round(avg_fragmentation_in_percent, 2) Avg_Frag_PCT, 
round(avg_page_space_used_in_percent,2) Avg_Page_Space_Used_in_Percent, Fragment_Count, Forwarded_Record_Count
from sys.indexes i cross apply sys.dm_db_index_physical_stats(db_id(),i.object_id, i.index_id,null,'detailed') ips)a inner join sys.tables t
on a.object_id = t.object_id
--where page_count >= 2000
--and avg_frag_pct >= 50
group by Table_Name, Index_Name, t.schema_id, page_count
