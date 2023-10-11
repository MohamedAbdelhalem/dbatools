SELECT [disk_letter], case when sum(case [style] when 'GPT' then 1 else 0 end) = 1 then 'GPT' else 'MBR' end
from (
select distinct [disk_letter], [style] 
FROM [master].[dbo].[disks])a
group by [disk_letter]

