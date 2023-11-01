--Enable SQLCMD mode first
:CONNECT 10.55.20.1
  
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D1SQLDBPrWV1).NodeWeight=0}"'
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D1SQLDBPrWV2).NodeWeight=0}"'
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D2SQLDBDrWV1).NodeWeight=1}"'
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D2SQLDBDrWV2).NodeWeight=1}"'
