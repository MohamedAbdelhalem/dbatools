alter PROCEDURE [dbo].[sp_big_table_bulk_delete](
@table_name				nvarchar(500) = '[PRODmfreportsdbBAB].[dbo].[middleware_requests]', 
@cluster_index_key		nvarchar(300) = '[id]')
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
min_EMAIL_ID,
max_EMAIL_ID
from master.dbo.MAIL_ARCHIVE_summary2
where deleted = 0
order by id 

open delete_cursor 
fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
while @@FETCH_STATUS = 0
begin

set @sql_delete = 'delete from '+@table_name+' where '+@cluster_index_key+' between '+cast(@cluster_index_key_from as varchar(50))+' and '+cast(@cluster_index_key_to as varchar(50))
--print(@sql_delete)
exec(@sql_delete)

update master.dbo.MAIL_ARCHIVE_summary2
set deleted = 1
where id = @summary_id

waitfor delay '00:00:05'

fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
end
close delete_cursor 
deallocate delete_cursor 

set nocount off
end
