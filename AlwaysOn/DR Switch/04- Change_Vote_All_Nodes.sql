exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D1T24DBSQPWV4).NodeWeight=0}"'
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D1T24DBSQPWV5).NodeWeight=0}"'
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D2T24DBSQPWV4).NodeWeight=1}"'
exec xp_cmdshell 'powershell.exe -Command "& {(get-ClusterNode D2T24DBSQPWV5).NodeWeight=1}"'
