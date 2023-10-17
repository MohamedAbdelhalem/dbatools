/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [RECID]
  FROM [T24_support].[dbo].[FBNK_STMT_PRINTED]
  where recid = 'SAR160300001-20230318'


--create table master.dbo.table_recids (id int identity(1,1), RECID varchar(1024))
declare @RECID varchar(255) = 'SAR160300001-20230318'
declare @loop int = 0
declare @table table (id int identity(1,1), RECID varchar(1024))

declare @table1 table (error_id int, [error_number] bigint, [error_message] varchar(max))
declare @target_date_table table (target_data varchar(max))
insert into @target_date_table
SELECT cast(xmlrecord as varchar(max))
  FROM [T24_support].[dbo].[FBNK_STMT_PRINTED]
  where recid = @RECID

select substring(target_data,@loop + 1, 1000)
from @target_date_table


select len(target_data) from @target_date_table
while @loop < (select len(target_data) from @target_date_table)
begin

--select id, substring(recid, 1, 1000 - charindex('>', reverse(recid)) + 1), charindex('>', reverse(recid)) + 1
--from master.dbo.table_recids

insert into master.dbo.table_recids
select substring(target_data,@loop + 1, 1000)
from @target_date_table

--insert into master.dbo.table_recids
--select s.value 
--FROM @target_date_table t cross apply master.dbo.Separator(substring(target_data,@loop + 1, 1000), '</') s

set @loop = @loop + 1000
end

select * from @table

insert into @table1
select row_number() over(order by em.id) , [error_number], substring([Error_Message], charindex('[',[Error_Message],4)+1, len([Error_Message])-2 - charindex('[',[Error_Message],4)) [error_message]
from (
select row_number() over(order by id) id, master.dbo.virtical_array(value, '>',3) [error_message]
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
where id in (select id + 1
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
where master.dbo.virtical_array(value, '>',2) like '%"message"%'))em
inner join (
select row_number() over(order by id) id, master.dbo.virtical_array(value, '>',3) [error_number]
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
where id in (select id + 1
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
--where master.dbo.virtical_array(value, '>',2) like '%"message"%')) en
where value like '%"error_number"%')) en
on em.id = en.id

insert into @table
select 
[error_number], 
[error_message], 
[disk volume],
master.dbo.numbersize(required_space,'byte') required_space, 
master.dbo.numbersize(substring(available_space, 1, charindex(' ', available_space)-1),'byte') available_space, 
master.dbo.numbersize(cast(required_space as bigint) - cast(substring(available_space, 1, charindex(' ', available_space)-1) as bigint),'byte') required_size_to_complete_restore
from (
select 
[error_number], 
[error_message], 
[disk volume],
substring([message],1, charindex(' ', [message])-1) required_space, 
ltrim(substring([message], charindex('while only', [message])+len('while only'),len([message]))) available_space
from (
select 
[error_number], 
[error_message], 
[disk volume],
substring(message,1, charindex('.',  message)-1) [message]
from (
select [error_number], [error_message], 
case when [error_number] = 3257 then ltrim(rtrim(replace(ltrim(substring([error_message],charindex('disk volume', [error_message]) + len('disk volume'), 6)),'''','"'))) end [disk volume],
case when [error_number] = 3257 then ltrim(substring([error_message],charindex('the database requires', [error_message]) + len('the database requires'), len([error_message]))) end [message]
from @table1)a)b)c

SELECT * from @
