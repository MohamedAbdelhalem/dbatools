set nocount on
exec xp_cmdshell 'mkdir "c:\part\"'
exec xp_cmdshell 'PowerShell.exe -Command "& {get-disk | select * > c:\part\disk_table.txt}"'
print('get-disk | select * > c:\part\disk_table.txt')
exec xp_cmdshell 'PowerShell.exe -Command "& {get-partition | select * > c:\part\partition_table.txt}"'
print('get-partition | select * > c:\part\partition_table.txt')
set nocount off
