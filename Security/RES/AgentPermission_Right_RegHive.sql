exec sp_configure 'show advanced options',1
go
reconfigure
go
exec sp_configure 'xp_cmdshell',1
go
reconfigure
go

declare @rvtable table (instance_name varchar(50), instance_version varchar(50))
declare @permissions table (output_text varchar(1000))
declare 
@key varchar(100), 
@instance_version varchar(1000), 
@instance_name varchar(255),
@powershell varchar(1000),
@serviceaccount varchar(100)

select @serviceaccount = 
case when service_account like 'NT Service\%' then substring(service_account,charindex('\',service_account)+1,len(service_account)) else service_account end
from sys.dm_server_services
where servicename like '%Agent%'

set @key = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' 
insert into @rvtable
exec xp_regread 'HKEY_LOCAL_MACHINE', @key, @@SERVICENAME

select @instance_version = instance_version 
from @rvtable

set @powershell = 'Powershell.exe -command "& {get-acl -path ''HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\'+@instance_version+'\SQLServerAgent'' | format-list}"' 
print(@powershell)

insert into @permissions
exec xp_cmdshell @powershell

select 
master.dbo.vertical_array(output_text,' ',1) text1,
master.dbo.vertical_array(output_text,' ',2) text2,
master.dbo.vertical_array(output_text,' ',3) text3, 
master.dbo.vertical_array(output_text,' ',4) text4,
master.dbo.vertical_array(output_text,' ',5) text5,
master.dbo.vertical_array(output_text,' ',6) text6,
master.dbo.vertical_array(output_text,' ',7) text7
from @permissions
where output_text like '%'+@serviceaccount+'%'
and output_text like '%Access%'

go
exec sp_configure 'xp_cmdshell',0
go
reconfigure
go
exec sp_configure 'show advanced options',0
go
