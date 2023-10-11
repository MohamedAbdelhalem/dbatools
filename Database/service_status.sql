declare @service varchar(100) = 'sql'
declare @ps table (output_text varchar(1000))
insert into @ps
exec xp_cmdshell 'powershell.exe get-service'

select 
[status],
substring(output_text, 1, charindex(' ', output_text)-1) [service_name],
ltrim(substring(output_text, charindex(' ', output_text)+1, len(output_text))) display_name
from (
select 
substring(output_text, 1, charindex(' ', output_text)-1) [status],
substring(output_text, charindex(' ', output_text)+1, len(output_text)) output_text
from (
select replace(convert(varbinary(1000), rtrim(output_text)),0x2020,' ') output_text
from @ps
where output_text like '%'+@service+'%')a)b
