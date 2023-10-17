use master
go

Create Procedure sp_Export_all_Logins
as
begin
declare 
@sql varchar(max),
@role varchar(100),
@name varchar(250), 
@sid_varb varbinary(max), 
@password_hash_varb varbinary(max), 
@sid varchar(max), 
@password_hash varchar(max), 
@type varchar(5), 
@default_database_name varchar(250), 
@policy_checked int, 
@expiration_checked int, 
@sysadmin int, 
@securityadmin int, 
@serveradmin int, 
@setupadmin int, 
@processadmin int, 
@diskadmin int, 
@dbcreator int, 
@bulkadmin int  

declare logins_cursor cursor fast_forward
for
select 
sl.name, sl.sid, sqll.password_hash, case isntuser when 1 then 'W' when 0 then 'S' end type, sp.default_database_name, isnull(sqll.is_policy_checked, 0) policy_checked, isnull(sqll.is_expiration_checked, 0) expiration_checked, sysadmin, securityadmin, serveradmin, setupadmin, processadmin, diskadmin, dbcreator, bulkadmin  
from sys.syslogins sl inner join sys.server_principals sp
on sl.name = sp.name
left outer join sys.sql_logins sqll
on sl.name = sqll.name
where hasaccess = 1
and sl.name not like '#%'
and sl.name not like 'NT %'
and sl.name != 'sa'
order by sl.name

open logins_cursor
fetch next from logins_cursor into 
@name, 
@sid_varb, 
@password_hash_varb,
@type, 
@default_database_name, 
@policy_checked, 
@expiration_checked, 
@sysadmin, 
@securityadmin, 
@serveradmin, 
@setupadmin, 
@processadmin, 
@diskadmin, 
@dbcreator, 
@bulkadmin 

while @@FETCH_STATUS = 0
begin 

Set @sid = CONVERT(VARCHAR(4000), @sid_varb, 1)
Set @password_hash = CONVERT(VARCHAR(4000), @password_hash_varb, 1)


if @type = 'S' 
begin
set @sql = 'Create Login ['+@name+'] With Password = '+@password_hash+' Hashed, SID = '+@sid+', Default_Database = ['+@default_database_name+'], Check_Policy = '+CASE WHEN @policy_checked = 1 THEN 'ON' ELSE 'OFF' END+', Check_Expiration = '+CASE WHEN @expiration_checked = 1 THEN 'ON' ELSE 'OFF' END
print(@sql)
if @sysadmin = 1 
 begin 
  set @role = 'Alter Server Role [sysadmin] Add Member ['+@name+']' 
  print(@role)
end
if @securityadmin = 1 
 begin 
  set @role = 'Alter Server Role [securityadmin] Add Member ['+@name+']' 
  print(@role)
end
if @serveradmin = 1 
 begin 
  set @role = 'Alter Server Role [serveradmin] Add Member ['+@name+']' 
  print(@role)
end
if @setupadmin = 1 
 begin 
  set @role = 'Alter Server Role [setupadmin] Add Member ['+@name+']' 
  print(@role)
end
if @processadmin = 1 
 begin 
  set @role = 'Alter Server Role [processadmin] Add Member ['+@name+']' 
  print(@role)
end
if @diskadmin = 1 
 begin 
  set @role = 'Alter Server Role [diskadmin] Add Member ['+@name+']' 
  print(@role)
end
if @dbcreator = 1 
 begin 
  set @role = 'Alter Server Role [dbcreator] Add Member ['+@name+']' 
  print(@role)
end
if @bulkadmin = 1 
 begin 
  set @role = 'Alter Server Role [bulkadmin] Add Member ['+@name+']' 
  print(@role)
end

end
else if @type = 'W' 
begin
set @sql = 'Create Login ['+@name+'] From Windows With Default_Database = ['+@default_database_name+']'
print(@sql)
if @sysadmin = 1 
 begin 
  set @role = 'Alter Server Role [sysadmin] Add Member ['+@name+']' 
  print(@role)
end
if @securityadmin = 1 
 begin 
  set @role = 'Alter Server Role [securityadmin] Add Member ['+@name+']' 
  print(@role)
end
if @serveradmin = 1 
 begin 
  set @role = 'Alter Server Role [serveradmin] Add Member ['+@name+']' 
  print(@role)
end
if @setupadmin = 1 
 begin 
  set @role = 'Alter Server Role [setupadmin] Add Member ['+@name+']' 
  print(@role)
end
if @processadmin = 1 
 begin 
  set @role = 'Alter Server Role [processadmin] Add Member ['+@name+']' 
  print(@role)
end
if @diskadmin = 1 
 begin 
  set @role = 'Alter Server Role [diskadmin] Add Member ['+@name+']' 
  print(@role)
end
if @dbcreator = 1 
 begin 
  set @role = 'Alter Server Role [dbcreator] Add Member ['+@name+']' 
  print(@role)
end
if @bulkadmin = 1 
 begin 
  set @role = 'Alter Server Role [bulkadmin] Add Member ['+@name+']' 
  print(@role)
end
end

fetch next from logins_cursor into 
@name, 
@sid_varb, 
@password_hash_varb,
@type, 
@default_database_name, 
@policy_checked, 
@expiration_checked, 
@sysadmin, 
@securityadmin, 
@serveradmin, 
@setupadmin, 
@processadmin, 
@diskadmin, 
@dbcreator, 
@bulkadmin 
end
close logins_cursor
deallocate logins_cursor
end