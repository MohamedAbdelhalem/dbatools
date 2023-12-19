select top 150 
'dbcc page(0,'+cast(master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) collate Arabic_100_CI_AS as varchar(10))+','+ 
cast(master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) collate Arabic_100_CI_AS  as varchar(10))+',3) with tableresults',
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid,
RECID, XMLRECORD,
CONVERT(varbinary(max),XMLRECORD) bcrypt,
CONVERT(nvarchar(max),CONVERT(varbinary(max),
STUFF(
STUFF(
STUFF(
STUFF(
STUFF(
STUFF(
STUFF(
STUFF(
STUFF(
CONVERT(varbinary(max),XMLRECORD)
, 10, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),1,8))
, 30, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),9,8))
, 50, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),17,8))
, 76, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),25,8))
, 99, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),33,8))
,119, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),41,8))
,140, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),49,8))
,169, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),57,8))
,189, 0, substring(CONVERT(varbinary(max),N'X!01M@02L#03R$04E%05C^06O&07R*08D(09'),65,8))
),2) acrypt
FROM [dbo].[F_BAB_H_O205]


dbcc traceon(3604)
declare @dbcc_page table (id int identity(1,1), ParentObject varchar(1000), Object varchar(1000), Field varchar(1000), VALUE varchar(1000)) 
declare @dbcc_page_links table (slot varchar(10), xml_pages varchar(1000), Field varchar(1000), object varchar(30), ClusterKey_VALUE varchar(1000)) 
insert into @dbcc_page (ParentObject, Object, Field, VALUE)
exec('dbcc page(0,18,31915586,3) with tableresults')

insert into @dbcc_page_links
select * from (
select 
master.dbo.vertical_array(dd.ParentObject,' ',7) slot, VALUE xml_page_ids, Field, object,
(select top 1 VALUE from @dbcc_page where Field = 'RECID' and id < dd.id order by id desc) ClusterKey_VALUE
from @dbcc_page dd )a
where object like 'Link%'
and Field = 'RowId'

select *
from (
select * from @dbcc_page_links)a 
pivot 
(max(xml_pages) for object in ([link 0],[link 1],[link 2],[link 3],[link 4],[link 5],[link 6]))p
order by ClusterKey_VALUE

select slot, 
isnull([1],'')+isnull([2],'')+isnull([3],'')+isnull([4],'')+isnull([5],'')+isnull([6],'')+isnull([7],'')+isnull([8],'')+isnull([9],'')
--[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22]
from (
select 
top 100 percent
ROW_NUMBER() over(partition by master.dbo.vertical_array(ParentObject,' ',2) order by id) pid,
master.dbo.vertical_array(ParentObject,' ',2) slot, 
master.dbo.vertical_array(VALUE,' ',4)+  
master.dbo.vertical_array(VALUE,' ',5)+ 
master.dbo.vertical_array(VALUE,' ',6)+ 
master.dbo.vertical_array(VALUE,' ',7) hex
from @dbcc_page
where Object like 'Memory Dump%'
order by id)a
Pivot (
max(hex) for pid in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22]))p
order by cast(slot as int)
--0x323930363B31303131
--70000400020000020016003a80323930363b31303131
--0400
--00
--8f010000001b360000681f000016ad0b030a0000005e2c000017ad0b030a00000000000000000000002f6ac2e23400
