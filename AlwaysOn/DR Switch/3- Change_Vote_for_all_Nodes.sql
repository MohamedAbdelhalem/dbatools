--Enable SQLCMD mode first
:CONNECT 10.55.20.1

exec sp_configure 'show advanced options',1
go
reconfigure 
go
exec sp_configure 'xp_cmdshell',1
go
reconfigure 
go

exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D1SQLDBPrWV1).NodeWeight=0}"'
go
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D1SQLDBPrWV2).NodeWeight=0}"'
go
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D2SQLDBDrWV1).NodeWeight=1}"'
go
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D2SQLDBDrWV2).NodeWeight=1}"'
