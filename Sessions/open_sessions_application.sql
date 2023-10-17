declare @mirror table (output_text varchar(1000))
insert into @mirror
exec xp_cmdshell 'netstat -ano | findstr 1433'

select count(*), HA_Node_IPs
from (
select IPSource HA_Node_IPs
from (
select 
substring(output_text, 1, charindex(':', output_text)-1) IPSource,
ltrim(substring(output_text, charindex(' ', output_text), len(output_text))) IPdestination
from (
select ltrim(substring(ltrim(rtrim(output_text)),charindex(' ',ltrim(rtrim(output_text))), len(ltrim(rtrim(output_text))))) output_text
from @mirror
where output_text like '%ESTABLISHED%')a)b
union 
select distinct
substring(IPdestination, 1, charindex(':', IPdestination)-1) Node_IP2
from (
select 
substring(output_text, 1, charindex(':', output_text)-1) IPSource,
ltrim(substring(output_text, charindex(' ', output_text), len(output_text))) IPdestination
from (
select ltrim(substring(ltrim(rtrim(output_text)),charindex(' ',ltrim(rtrim(output_text))), len(ltrim(rtrim(output_text))))) output_text
from @mirror
where output_text like '%ESTABLISHED%')a)b)c
group by HA_Node_IPs
order by HA_Node_IPs

