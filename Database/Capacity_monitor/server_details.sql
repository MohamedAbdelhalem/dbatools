use master
go
if (select value_in_use from sys.configurations where name = 'show advanced options') = 0
begin
exec sp_configure 'show advanced options',1
end
go
reconfigure with override
go
if (select value_in_use from sys.configurations where name = 'xp_cmdshell') = 0
begin
exec sp_configure 'xp_cmdshell',1
end
go
reconfigure with override
go

if object_id('[dbo].[server_details]') is not null
begin
drop table [dbo].[server_details]
end
go
create table [dbo].[server_details] (server_name varchar(100), server_ip varchar(100), port varchar(10), app_name varchar(100), location varchar(100), [function] varchar(100))
go

declare @server_name varchar(100), @IpAddress varchar(100), @port varchar(10)
declare @hostname_table table (output_text varchar(100))
insert into @hostname_table
exec('xp_cmdshell ''hostname''')

select @server_name = output_text 
from @hostname_table 
where output_text is not null

declare @table table (id int identity(1,1), output_Text varchar(max))
declare @xp varchar(200), @id int
set @xp = 'ipconfig'
insert into @table
exec xp_cmdshell @xp

select top 1 @id = id 
from (
select id, case when charindex('.',ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))) > 0 then 1 else 0 end has_gateway
from @table
where id in (select id + 2
from @table
where output_Text like '%IPV4%'))a
where has_gateway = 1

select @IpAddress = ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))-- IP_address
from @table
where id = @id - 2

select top 1 @port = port
from sys.dm_tcp_listener_states
where ip_address ='0.0.0.0'
and type = 0
order by listener_id

insert into [dbo].[server_details]
select @server_name, @IpAddress, @port, 'NEW_SMS',
case 
when master.dbo.vertical_array(@IpAddress,'.',2) in ('32','33','36') then 'SDC'
when master.dbo.vertical_array(@IpAddress,'.',2) in ('0','1','2','4','5') then 'PDC' end, 
case 
when substring(@server_name, 1,2) = 'D1' and right(@server_name,2) = 'v1' then 'Primary'
when substring(@server_name, 1,2) = 'D1' and right(@server_name,2) = 'v4' and master.dbo.vertical_array(@IpAddress,'.',2) in ('4') then 'Primary'
when substring(@server_name, 1,2) = 'D1' and right(@server_name,2) = 'v4' and master.dbo.vertical_array(@IpAddress,'.',2) in ('1') then 'Primary'
when substring(@server_name, 1,2) = 'D1' and right(@server_name,2) = 'v3' and master.dbo.vertical_array(@IpAddress,'.',2) in ('1') then 'Primary'
else --except new-kony
'Secondary'
end

update [dbo].[server_details]
set [function] = case location when 'PDC' then 'Primary' else 'Secondary' end

select * from [dbo].[server_details]
