declare @type int = 3

declare @key varchar(1000)

declare @cmd varchar(1000)

declare @Protocols table (output_text varchar(2000))

declare @Protocols_levels  table (keys varchar(2000))

declare @Protocols_levels2 table (output_text varchar(2000), parent_key varchar(2000))

insert into @Protocols

exec xp_cmdshell 'PowerShell.exe -Command "& {Get-childItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" | Select name }"'
 
declare protocol_cursor cursor fast_forward

for

select replace(output_text,'HKEY_LOCAL_MACHINE','HKLM:')

from @Protocols

where output_text like 'HKEY_LOCAL_MACHINE%'
 
open protocol_cursor

fetch next from protocol_cursor into @key

while @@FETCH_STATUS = 0

begin
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Get-childItem -Path '+''''''+ltrim(rtrim(@key))+''''''+' | Select name}"'''

insert into @Protocols_levels (keys)

exec(@cmd)

--print(@cmd)
 
fetch next from protocol_cursor into @key

end

close protocol_cursor 

deallocate protocol_cursor
 
declare client_server_keys cursor fast_forward

for

select replace(keys,'HKEY_LOCAL_MACHINE','HKLM:')

from @Protocols_levels

where keys like 'HKEY_LOCAL_MACHINE%'

and keys not like '%..%'
 
open client_server_keys

fetch next from client_server_keys into @key

while @@FETCH_STATUS = 0

begin
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Get-ItemProperty -Path '+''''''+ltrim(rtrim(@key))+''''''+' | Select DisabledByDefault, Enabled}"'''

insert into @Protocols_levels2 (output_text)

exec(@cmd)

--print(@cmd)

update @Protocols_levels2 set parent_key = @key where parent_key is null

fetch next from client_server_keys into @key

end

close client_server_keys 

deallocate client_server_keys
 
if @type in (1,3)

begin
 
select protocol_name, --type, 

sum(DisabledByDefault) DisabledByDefault, 

case 

when sum(DisabledByDefault) = 2 and protocol_name != 'TLS 1.2' then 'correct' 

when sum(DisabledByDefault) = 0 and protocol_name  = 'TLS 1.2' then 'correct' 

else 'something wrong' end DisabledByDefault_check,

sum(Enabled) Enabled, 

case 

when sum(Enabled) = 2 and protocol_name = 'TLS 1.2' then 'correct' 

when sum(Enabled) = 0 and protocol_name != 'TLS 1.2' then 'correct' 

else 'something wrong' end Enabled_check

from (

select 

reverse(master.dbo.vertical_array(reverse(parent_key), '\', 2)) protocol_name,

reverse(master.dbo.vertical_array(reverse(parent_key), '\', 1)) type,

cast(substring(ltrim(rtrim(output_text)), 1, charindex(' ',ltrim(rtrim(output_text)))-1) as decimal(30,0)) DisabledByDefault,

case cast(substring(ltrim(rtrim(output_text)), charindex(' ',ltrim(rtrim(output_text)))+1, len(output_text)) as decimal(30,0)) when 0 then 0 else 1 end Enabled

from @Protocols_levels2

where output_text is not null

and output_text not like '%----%'

and output_text not like '%abled%')a

group by protocol_name

end

if @type in (2,3)

begin

select count(*) protocols,  case when DisabledByDefault_check = 'correct' and Enabled_check = 'correct' then 'correct' else 'need configuration' end configuration_status

from (

select protocol_name,  

sum(DisabledByDefault) DisabledByDefault, 

case 

when sum(DisabledByDefault) = 2 and protocol_name != 'TLS 1.2' then 'correct' 

when sum(DisabledByDefault) = 0 and protocol_name  = 'TLS 1.2' then 'correct' 

else 'something wrong' end DisabledByDefault_check,

sum(Enabled) Enabled, 

case 

when sum(Enabled) = 2 and protocol_name = 'TLS 1.2' then 'correct' 

when sum(Enabled) = 0 and protocol_name != 'TLS 1.2' then 'correct' 

else 'something wrong' end Enabled_check

from (

select 

reverse(master.dbo.vertical_array(reverse(parent_key), '\', 2)) protocol_name,

reverse(master.dbo.vertical_array(reverse(parent_key), '\', 1)) type,

cast(substring(ltrim(rtrim(output_text)), 1, charindex(' ',ltrim(rtrim(output_text)))-1) as decimal(30,0)) DisabledByDefault,

case cast(substring(ltrim(rtrim(output_text)), charindex(' ',ltrim(rtrim(output_text)))+1, len(output_text)) as decimal(30,0)) when 0 then 0 else 1 end Enabled

from @Protocols_levels2

where output_text is not null

and output_text not like '%----%'

and output_text not like '%abled%')a

group by protocol_name)b

group by case when DisabledByDefault_check = 'correct' and Enabled_check = 'correct' then 'correct' else 'need configuration' end

end

 
