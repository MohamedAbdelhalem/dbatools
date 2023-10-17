declare @cmd varchar(1000), @folder varchar(1500) = 'I:\SQLSERVER\DATA\MSSQL12.MSSQLSERVER\MSSQL\DatabaseAuditing'

select service_account 
from sys.dm_server_services
where filename like '%sqlservr.exe%'

set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Get-Acl '''''+@folder+''''' | Select -Expand AccessToString}"'''
print(@cmd)
exec(@cmd)
