USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_big_table_bulk_delete]    Script Date: 3/9/2023 9:33:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[sp_big_table_bulk_delete](
@table_name				nvarchar(500) = '[PRODmfreportsdbBAB].[dbo].[middleware_requests]', 
@cluster_index_key		nvarchar(300) = '[id]',
@stop_date_column		nvarchar(300) = '[ts]')
as
begin

declare 
@summary_id				bigint,
@cluster_index_key_from bigint, 
@cluster_index_key_to	bigint,
@sql_delete				nvarchar(max)

set nocount on
declare delete_cursor cursor fast_forward
for
select
id,
[from_unique_column],
[to_unique_column]
from [master].[dbo].[middleware_requests_summary2]
where unique_id = 1
and deleted = 0
order by id 

open delete_cursor 
fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
while @@FETCH_STATUS = 0
begin

set @sql_delete = 'delete from '+@table_name+' where '+@cluster_index_key+' between '+cast(@cluster_index_key_from as varchar(50))+' and '+cast(@cluster_index_key_to as varchar(50))
--print(@sql_delete)
exec(@sql_delete)

update [master].[dbo].[middleware_requests_summary2]
set deleted = 1
where id = @summary_id

waitfor delay '00:00:05'

fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
end
close delete_cursor 
deallocate delete_cursor 

set nocount off
end
