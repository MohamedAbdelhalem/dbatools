declare @FilestreamConfiguredLevel int = 2

select 
FileStream_OS_value, FileStream_OS, FileStream_Instance_value, FileStream_Instance, s.id, s.value configuration_script
from (
select 
SERVERPROPERTY('FilestreamConfiguredLevel') [FileStream_OS_value],
case SERVERPROPERTY('FilestreamConfiguredLevel')
when 0 then 'is disabled'
when 1 then 'is enabled for Transact-SQL access'
when 2 then 'is enabled for Transact-SQL and local Win32 streaming access'
when 3 then 'is enabled for Transact-SQL and both local and remote Win32 streaming access'
end [FileStream_OS],
(select value_in_use from sys.configurations where configuration_id = 1580) [FileStream_Instance_value],
case (select value_in_use from sys.configurations where configuration_id = 1580)
when 0 then 'is disabled'
when 1 then 'is enabled for Transact-SQL access'
when 2 then 'is enabled for Transact-SQL and local Win32 streaming access'
end [FileStream_Instance],
case when 
(select value_in_use from sys.configurations where configuration_id = 1580) != @FilestreamConfiguredLevel
then 'exec sp_configure ''filestream access level'', '+CAST(configuration_id as varchar(10))+char(10)+'go'+char(10)+'reconfigure with override'+char(10)+'go'
else 'Already configured'
end configuration_script
from (
values 
(0, 'Disable'),
(1, 'Transact-SQL access'),
(2, 'Full access - Transact-SQL and local Win32 streaming access')) 
as filestream_config (configuration_id, [description])
where configuration_id = @FilestreamConfiguredLevel)a
cross apply master.dbo.separator(configuration_script, char(10)) s
order by s.id

