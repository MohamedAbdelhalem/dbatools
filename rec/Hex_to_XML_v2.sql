USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Hex_to_XML]    Script Date: 3/2/2023 1:57:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Hex_to_XML_v2]
(@hex_record varchar(max), @xmlrecord nvarchar(max) output, @print int = 3)
as
begin
declare @xml_table  table (id int identity(1,1), xml_value nvarchar(max), hex_value varchar(max), identify varchar(100))
declare @xml_result table (id int,				 xml_value nvarchar(max), hex_value varchar(max), identify varchar(100), desc_identify int) 
set nocount on

declare @pos bigint
declare @xml_value nvarchar(max), @hex_value varchar(max)
declare @xml nvarchar(max) 
set @xml = substring(@hex_record,charindex('dfff01',@hex_record), len(@hex_record))
select @xml = substring(@xml, 11, len(@xml))

declare @pos1 bigint, @pos2 bigint, @ident varchar(100)
while @xml not like 'f7f7%'
begin

select @pos1 = master.dbo.fn_pos(substring(@xml,1,24),1), @pos2 = master.dbo.fn_pos(substring(@xml,1,24),2)
select @hex_value = 
			   case 
			   when substring(@xml,1,2) in ('f0','f5','f6','f7','f8','11') then substring(@xml, @pos1, @pos2 * 4) 
			   when substring(@xml,1,2) in ('ef')						   then case when @pos2 = 0 then N'' else substring(@xml,17,master.dbo.Hex_to_Decimal(substring(@xml, 15, 2)) * 4) end
			   end

select @xml_value = 
			   isnull(replace(replace(replace(replace(replace(master.dbo.Hex_to_Text_NCHar(upper(case 
			   when substring(@xml,1,2) in ('f0','f5','f6','f7','f8','11') then substring(@xml, @pos1, @pos2 * 4) 
			   when substring(@xml,1,2) in ('ef')						   then case when @pos2 = 0 then N'' else substring(@xml,17,master.dbo.Hex_to_Decimal(substring(@xml, 15, 2)) * 4) end
			   end)),N'&',N'&amp;'),N'<',N'&lt;'),N'>',N'&gt;'),N'''',N'&apos;'),N'"',N'&quot;'),'')

set @ident = case when @pos2 = 0 then N'ff' else case when charindex('11', substring(@xml,1,14)) = 0 and substring(@xml, 1,2) = 'ef' then substring(@xml,1,@pos1) else substring(@xml,1,@pos1+1-4) end end

select @xml =  case 
			   when substring(@xml,1,2) in ('f0','f5','f6','f7','f8','11') then substring(@xml, @pos1 + (@pos2 * 4), len(@xml))
			   when substring(@xml,1,2) in ('ef')						   then case when @pos2 = 0 then substring(@xml, 13, len(@xml)) else substring(@xml, 17 + (master.dbo.Hex_to_Decimal(substring(@xml, 15, 2)) * 4), len(@xml)) end
			   end
--select @xml, @xml_value, @ident
insert into @xml_table (xml_value, hex_value, identify) values (@xml_value, @hex_value,@ident)
end

insert into @xml_result 
select 
*, 
case 
when identify in   ('f5f0','f7f0','f5f7f0')																	then 1  -- Tag
when identify like 'ef%f8%11' and (identify not like '%f6%11' and len(identify) != 6) or (identify = 'ff')	then 2 -- Tag Value 
when (identify like 'f7f8%' and len(identify) = 8) or (identify like 'ef%f0' and len(identify) = 14) then 3  -- Letter Identifier 
when (identify like  '%f7f8%f6%11'and len(identify) in (12,14) and identify not in ('f511','f0')) 
  or ((select case when (identify like 'f7f8%' and len(identify) in (8,12)) or (identify like 'ef%f0' and len(identify) = 14) then 3 else 0 end is_3 from @xml_table where id = (xt.id-1)) =  3  and identify not in ('f511','f0')) then 4  -- Equal no 
when identify like  'f511'																			then 5  -- Inside Value 
when identify in   ('f0')		and id > 8															then 6  -- Letter Identifier 2 
when identify like  '%f6%11' and len(identify) in (6,14)
and ((select case when (identify like 'f7f8%' and len(identify) = 8) or (identify like 'ef%f0' and len(identify) = 14) then 3 else 0 end is_3 from @xml_table where id = (xt.id-1)) !=  3) then 7  -- Inside Value 2
else 0
end desc_identify
from @xml_table xt
where xml_value is not null
order by id

if @print = 1
begin
select *, len(identify) from @xml_result --where desc_identify in (3,4,7) --order by desc_identify, id
end
else 
if @print = 2
begin

select id, xml_value, identify, desc_identify, col_id, id_3, id_4, id_33, id_44, missing_5, id_3_7, id_4_7, id_33_7, id_44_7, missing_5_4, id_3_4, id_4_4,--missing_2,
case 
when id = 1				then '<'+xml_value+case when (select id from @xml_result where xml_value = 'id' and id < 8) = 2 then ' '+col_id+' xml:space="preserve"' else ' xml:space="preserve" '+col_id end +'>'
when id = 10000			then '</'+xml_value+'>'
when desc_identify = 2  then case when identify = 'ff' then '<'+col_id+' />' else '<'+col_id+'>'+xml_value+'</'+col_id+'>' end
when desc_identify = 5  then '<'+col_id+' '+isnull(id_3+'="'+id_4+'"','')+' '+isnull(id_33+'="'+id_44+'"','')+'>'+xml_value+'</'+col_id+'>'
when missing_5 = 0      then '<'+col_id+' '+isnull(id_3_7+'="'+id_4_7+'"','')+' '+isnull(id_33_7+'="'+id_44_7+'"','')+'/>'
when missing_5_4 = 0    then '<'+col_id+' '+isnull(id_3_4+'="'+id_4_4+'"','')+'/>'
end
from (
select
id, xml_value, identify, desc_identify, 
case 
when id = 1			   then 'id="'+(select xml_value from @xml_result where id in (select id + 1 from @xml_result where xml_value = 'id' and id < 8))+'"'
when desc_identify = 1 then ''
when desc_identify = 2 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 3 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 4 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 5 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 6 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
end col_id,
case desc_identify 
when 5 then (select xml_value from @xml_result where id in (isnull((select max(id) id from @xml_result where id < xt.id and desc_identify = 4),(select max(id) id from @xml_result where id < xt.id and desc_identify = 2))))
end id_4,
case desc_identify 
when 5 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 3))
end id_3,
case when desc_identify = 5 and (select desc_identify from @xml_result where id = (xt.id-1)) = 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where desc_identify = 6))
end id_33,
case when desc_identify = 5 then (select xml_value from @xml_result where id = (xt.id-1) and desc_identify = 7)
end id_44,
case when desc_identify in (7) then case when (select desc_identify from @xml_result where id = (xt.id+1)) != 5 then 0 else 1 end
end missing_5,
case desc_identify 
when 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 4))
end id_4_7,
case desc_identify 
when 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 3))
end id_3_7,
case when desc_identify = 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where desc_identify = 6))
end id_33_7,
case when desc_identify = 7 then xml_value 
end id_44_7,
case when desc_identify in (4) then case when (select desc_identify from @xml_result where id = (xt.id+1)) not in (5,6,7) then 0 else 1 end
end missing_5_4,
case desc_identify 
when 4 then xml_value end id_4_4,
case desc_identify 
when 4 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 3))
end id_3_4
from @xml_result xt
union
select 10000, xml_value, identify, desc_identify, '','','','','','','','','','','','',''
from @xml_result 
where id = 1)a
order by id
end
if @print = 3
begin

select @xmlrecord = isnull(@xmlrecord,'') + char(10) + case when id = 10000 then '' else '  ' end +
xmlrecord
from (
select id, 
case 
when id = 1				then '<'+xml_value+case when (select id from @xml_result where xml_value = 'id' and id < 8) = 2 then ' '+col_id+' xml:space="preserve"' else ' xml:space="preserve" '+col_id end +'>'
when id = 10000			then '</'+xml_value+'>'
when desc_identify = 2  then case when identify = 'ff' then '<'+col_id+' />' else '<'+col_id+'>'+xml_value+'</'+col_id+'>' end
when desc_identify = 5  then '<'+col_id+' '+isnull(id_3+'="'+id_4+'"','')+' '+isnull(id_33+'="'+id_44+'"','')+'>'+xml_value+'</'+col_id+'>'
when missing_5 = 0      then '<'+col_id+' '+isnull(id_3_7+'="'+id_4_7+'"','')+' '+isnull(id_33_7+'="'+id_44_7+'"','')+'/>'
when missing_5_4 = 0    then '<'+col_id+' '+isnull(id_3_4+'="'+id_4_4+'"','')+'/>'
end xmlrecord
from (
select
id, xml_value, identify, desc_identify, 
case 
when id = 1			   then 'id="'+(select xml_value from @xml_result where id in (select id + 1 from @xml_result where xml_value = 'id' and id < 8))+'"'
when desc_identify = 1 then ''
when desc_identify = 2 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 3 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 4 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 5 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 6 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
when desc_identify = 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 1))
end col_id,
case desc_identify 
when 5 then (select xml_value from @xml_result where id in (isnull((select max(id) id from @xml_result where id < xt.id and desc_identify = 4),(select max(id) id from @xml_result where id < xt.id and desc_identify = 2))))
end id_4,
case desc_identify 
when 5 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 3))
end id_3,
case when desc_identify = 5 and (select desc_identify from @xml_result where id = (xt.id-1)) = 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where desc_identify = 6))
end id_33,
case when desc_identify = 5 then (select xml_value from @xml_result where id = (xt.id-1) and desc_identify = 7)
end id_44,
case when desc_identify in (7) then case when (select desc_identify from @xml_result where id = (xt.id+1)) != 5 then 0 else 1 end
end missing_5,
case desc_identify 
when 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 4))
end id_4_7,
case desc_identify 
when 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 3))
end id_3_7,
case when desc_identify = 7 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where desc_identify = 6))
end id_33_7,
case when desc_identify = 7 then xml_value 
end id_44_7,
case when desc_identify in (4) then case when (select desc_identify from @xml_result where id = (xt.id+1)) not in (5,6,7) then 0 else 1 end
end missing_5_4,
case desc_identify 
when 4 then xml_value end id_4_4,
case desc_identify 
when 4 then (select xml_value from @xml_result where id in (select max(id) id from @xml_result where id < xt.id and desc_identify = 3))
end id_3_4
from @xml_result xt
union
select 10000, xml_value, identify, desc_identify, '','','','','','','','','','','','',''
from @xml_result 
where id = 1)a
where (id not in (2,3,4,5,6)
and desc_identify not in (1,3,4,6,7)
or missing_5 = 0
or missing_5_4 = 0)
)a
where xmlrecord is not null
order by id

set nocount off
end

end
