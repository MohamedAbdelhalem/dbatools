CREATE Function dbo.sql_ports()
returns @tb table ([Ports] varchar(50))
as
begin
declare 
@SqlVersionPath varchar(500),
@Ports varchar(100)

select @SqlVersionPath =
'MSSQL'+
substring(cast(value_data as varchar(200)),1,charindex('.',cast(value_data as varchar(200)))-1)+'.'+
case when charindex('\',name) = 0 then 'MSSQLSERVER' else substring(name, charindex('\',name)+1,len(name)) end+'\'+
case when charindex('\',name) = 0 then 'MSSQLSERVER' else substring(name, charindex('\',name)+1,len(name)) end
from sys.dm_server_registry r cross apply sys.servers s
where r.value_name = 'CurrentVersion'
and s.server_id = 0

select @ports = cast(value_data as varchar(200)) 
from sys.dm_server_registry
where registry_key like 'HKLM\Software\Microsoft\Microsoft SQL Server\'+@SqlVersionPath+'\SuperSocketNetLib\Tcp\IPAll'
and value_name = 'TcpPort'

insert into @tb
select ltrim(rtrim(value))
from master.dbo.Separator(@ports,',')

return
end
