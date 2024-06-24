SELECT 
s.servicename,
s.service_account,
sql_memory_model_desc,
case sql_memory_model_desc 
when 'CONVENTIONAL' then 'privilege isn''t granted.'
when 'LOCK_PAGES' then 'privilege is granted.'
when 'LARGE_PAGES' then 'privilege is granted in Enterprise mode with Trace Flag 834 enabled.'
end "Lock pages in memory (LPIM)",
s.instant_file_initialization_enabled
FROM sys.dm_os_sys_info info cross apply sys.dm_server_services s
where s.servicename like 'SQL Server ('+isnull(cast(SERVERPROPERTY('InstanceName') as varchar(100)),'MSSQLSERVER')+'%'
