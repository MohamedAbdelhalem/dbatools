USE [T24Prod]
GO
/****** Object:  StoredProcedure [dbo].[rebuild_fragmented_tables]    Script Date: 8/31/2023 8:54:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[rebuild_fragmented_tables]
as
begin
declare @rebuild_sql varchar(1500)
declare i cursor fast_forward
for
select syntax
from (
select distinct 'ALTER INDEX ['+i.name+'] ON ['+t.name+'] REBUILD PARTITION = ALL WITH (ONLINE=ON, FILLFACTOR = 80, MAXDOP = 1)' syntax
from sys.indexes i inner join sys.tables t
on i.object_id = t.object_id
where t.name in (select table_name from dbo.table_rebuild where is_disable = 0))a
order by syntax

open i
fetch next from i into @rebuild_sql
while @@FETCH_STATUS = 0
begin

exec(@rebuild_sql)

fetch next from i into @rebuild_sql
end
close i
deallocate i
end

