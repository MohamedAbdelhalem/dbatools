USE [master]

GO
declare @ag_alwaysOn varchar(300) = 'AG_WFM'
declare @ag_id uniqueidentifier, @ag_name varchar(300), @db_name varchar(300), @sql varchar(1500)
declare 
@error_number  int,
@err_severity  int,
@error_state   int,
@error_line    varchar(100),
@error_message varchar(1000)

select @ag_id = group_id, @ag_name = name 
from sys.availability_groups
where name = @ag_alwaysOn

declare db cursor fast_forward
for
select database_name 
from sys.availability_databases_cluster
where group_id = @ag_id

open db
fetch next from db into @db_name
while @@FETCH_STATUS = 0
begin
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] REMOVE DATABASE ['+@db_name+'];'
begin try
exec(@sql)
print('Database ['+@db_name+'] has been removed successfully from AG ['+@ag_name+']')
end try
begin catch
SELECT
@db_name,
ERROR_NUMBER(),
ERROR_SEVERITY(),
ERROR_STATE(),
ERROR_LINE(),
ERROR_MESSAGE()
end catch
fetch next from db into @db_name
end
close db
deallocate db


--restore Database [Biometrics] with recovery
--restore Database [BPWHATIFDB] with recovery
--restore Database [CentralApp] with recovery
--restore Database [CentralContact] with recovery
--restore Database [CentralDWH] with recovery
--restore Database [CommonDB] with recovery
--restore Database [ETLSTAGINGDB] with recovery
--restore Database [LocalContact] with recovery
--restore Database [PCMON] with recovery
--restore Database [ReportServer] with recovery
--restore Database [ReportServerTempDB] with recovery
--restore Database [SpeechAnalytics] with recovery
--restore Database [SpeechProducts] with recovery
--restore Database [TextDB] with recovery
--restore Database [BPWAREHOUSEDB] with recovery
--restore Database [BPMAINDB] with recovery



