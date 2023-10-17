declare @role varchar(100)
select @role = role_desc
from sys.dm_hadr_availability_replica_states 
where is_local = 1

if @role = 'PRIMARY'
begin

declare
@table_name			varchar(500) = 'F_BAB_L_REPORTS_LINES',
@cluster_key_column varchar(300) = 'RECID',
@with_condition		int = 1,
@where				varchar(1500) = 'where RECID like ''LD.CASHFLOW-%''',
@bulk				int = 3000

truncate table [master].[dbo].[log_delete];

declare @sql nvarchar(max)
create table #temp_delete_clause (group_id int, RECID varchar(1000))

set @sql = 'select 
master.dbo.gBulk(row_number() over(order by '+@cluster_key_column+'),'+cast(@bulk as varchar(100))+') group_id, 
'+@cluster_key_column+'
from '+@table_name+'
'+case when @with_condition = 1 then @where else '' end

insert into #temp_delete_clause
exec(@sql)

create nonclustered index idx_group_id_temp_delete_clause on #temp_delete_clause (group_id)

declare @group_id int, @min_value varchar(1000), @max_value varchar(1000)
declare i cursor fast_forward
for
select group_id, min(RECID), max(RECID)
from #temp_delete_clause
group by group_id
order by group_id

open i
fetch next from i into @group_id, @min_value, @max_value
while @@FETCH_STATUS = 0
begin

set @sql = 'delete 
from '+@table_name+'
where '+@cluster_key_column+' between '+''''+@min_value+''''+' and '+''''+@max_value+''''
exec(@sql)
insert into [master].[dbo].[log_delete] (group_id) values (@group_id)
waitfor delay '00:00:01'

fetch next from i into @group_id, @min_value, @max_value
end
close i
deallocate i
drop table #temp_delete_clause
end