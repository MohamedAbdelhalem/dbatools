--declare identify varchar(100) = 'f5f7f823f60611'
select * 
from (
select id, identify, xml_value,
case 
when identify in   ('f5f0','f7f0','f5f7f0')																	then 1  -- Tag
--when identify like  'ef000%'	and identify not like '%f60611' and identify not like '%f60511' and identify not like '%f6%11'	then 2 -- Tag Value 
when identify like 'ef%f8%11' 
and (identify not like '%f6%11' and len(identify) != 6) or (identify = 'ff')	then 2 -- Tag Value 
when (identify like 'f7f8%' and len(identify) = 8) or (identify like 'ef%f0' and len(identify) = 14) then 3  -- Letter Identifier 
--when identify like  '%f60611'	or identify like 'ef00%f60511'	or identify like 'f7f8%f60511'		then 4  -- Equal no 
when (identify like  '%f7f8%f6%11'and len(identify) in (12,14) and identify not in ('f511','f0')) 
  or ((select case when (identify like 'f7f8%' and len(identify) in (8,12)) or (identify like 'ef%f0' and len(identify) = 14) then 3 else 0 end is_3 from xml_table2 where id = (xt.id-1)) =  3  and identify not in ('f511','f0')) then 4  -- Equal no 
when identify like  'f511'																			then 5  -- Inside Value 
when identify in   ('f0')		and id > 8															then 6  -- Letter Identifier 2 
when identify like  '%f6%11' and len(identify) in (6,14)
and ((select case when (identify like 'f7f8%' and len(identify) = 8) or (identify like 'ef%f0' and len(identify) = 14) then 3 else 0 end is_3 from xml_table2 where id = (xt.id-1)) !=  3) then 7  -- Inside Value 2
else 0
end desc_identify
from xml_table2 xt
where xml_value is not null)a
where desc_identify = 4
order by id


select * from master.dbo.xml_table2
--10.38.5.65