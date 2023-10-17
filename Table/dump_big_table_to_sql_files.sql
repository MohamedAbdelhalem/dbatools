declare 
@from_unique_column varchar(300), @to_unique_column varchar(300), 
@from_id bigint, @to_id bigint, 
@bcp_sql varchar(4000) 
declare exp_cur cursor fast_forward
for
select 
from_id, to_id, from_unique_column, to_unique_column 
from master.dbo.[FBNK_FUNDS_TRANSFER#HIS_summary2]
where id between 1 and 10
order by id 

set nocount on
open exp_cur
fetch next from exp_cur into @from_id, @to_id, @from_unique_column, @to_unique_column
while @@FETCH_STATUS = 0
begin

set @bcp_sql = 'bcp "exec [T24PROD_UAT].[dbo].[sp_dump_table] @table = ''dbo.[FBNK_FUNDS_TRANSFER#HIS]'', @new_name = ''dbo.[FBNK_FUNDS_TRANSFER#HIS__test]'', @columns = '' recid , XMLRECORD  '', @where_records_condition = ''where [recid] between '+''''+''''+@from_unique_column+''''+''''+' and '+''''+''''+@to_unique_column+''''+''''+' order by [recid]'',@with_computed = 0, @header = 0, @bulk = 10000" queryout "T:\Export\FBNK_FUNDS_TRANSFER#HIS_from_'+cast(@from_id as varchar(50))+'_to_'+cast(@to_id as varchar(50))+'.sql"  -d T24PROD_UAT -T -n -c'
print @bcp_sql
exec xp_cmdshell @bcp_sql

fetch next from exp_cur into @from_id, @to_id, @from_unique_column, @to_unique_column
end
close exp_cur
deallocate exp_cur
set nocount off
