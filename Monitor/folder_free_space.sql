use master
go
declare @folder varchar(1000) = '\\npci2.d2fs.albilad.com\DBTEMP\D2T24DBSQIWV4\T24PROD_UAT\FULL'
--restore headeronly from disk ='\\npci2.d2fs.albilad.com\DBTEMP\R21_BAB_DEV_Full_2023_04_17__01_29_pm.bak'
declare @xp varchar(1010) = 'dir cd "'+@folder+'"'
declare @output table (output_text varchar(1000))
insert into @output
exec xp_cmdshell @xp

--to get the service account of the sql server
--select servicename, service_account  from sys.dm_server_services

select case when folder_free_space = 'The user name or password is incorrect.'
then 'The user name or password is incorrect for service account ['+
(select service_account from sys.dm_server_services where servicename like 'SQL Server (%') + ']' 
else
folder_free_space 
end
folder_free_space
from (
select master.dbo.numberSize(cast(replace(substring(output_text,1,charindex(' ',output_text)-1),',','') as float)/1024, 'kb') folder_free_space
from (
select ltrim(rtrim(substring(output_text,charindex(')',output_text)+1, len(output_text)))) output_text
from @output
where output_text like '%bytes free%')a
union all 
select output_Text
from @output
where output_text = 'Access is denied.'
union all 
select output_Text
from @output
where output_text = 'The network path was not found.'
union all 
select output_Text
from @output
where output_text = 'The user name or password is incorrect.')b

select * from (
select 
convert(datetime,convert(varchar(10),convert(datetime,substring(date_time,1,charindex(' ',date_time)-1),120),120)+substring(date_time,charindex(' ',date_time)+1,len(date_time)),120) Creation_Date,
master.dbo.numbersize(replace(substring(output_text, 1, charindex(' ', output_text)-1),',',''),'byte') file_size,
master.dbo.numbersize(sum(cast(replace(substring(output_text, 1, charindex(' ', output_text)-1),',','') as float)) over(partition by convert(datetime,convert(varchar(10),convert(datetime,substring(date_time,1,charindex(' ',date_time)-1),120),120)+substring(date_time,charindex(' ',date_time)+1,len(date_time)),120)),'byte') total_files_size,
substring(output_text, charindex(' ', output_text)+1, len(output_text)) backup_file
from (
select ltrim(rtrim(substring(output_text, 1, charindex('M ', output_text)-2))) date_time,
ltrim(rtrim(substring(output_text, charindex('M ', output_text)+2, len(output_text)))) output_text
from @output
where output_text like '%M %'
and output_text not like '%<DIR>%')a)b
--where Creation_Date = '2023-07-20 03:00:00.000'
--order by cast(replace(substring(output_text, 1, charindex(' ', output_text)-1),',','') as bigint) desc
order by creation_date desc


select COUNT(*) Nr_files, Creation_Date, total_files_size 
from (
select 
convert(datetime,convert(varchar(10),convert(datetime,substring(date_time,1,charindex(' ',date_time)-1),120),120)+substring(date_time,charindex(' ',date_time)+1,len(date_time)),120) Creation_Date,
master.dbo.numbersize(replace(substring(output_text, 1, charindex(' ', output_text)-1),',',''),'byte') file_size,
master.dbo.numbersize(sum(cast(replace(substring(output_text, 1, charindex(' ', output_text)-1),',','') as float)) over(partition by convert(datetime,convert(varchar(10),convert(datetime,substring(date_time,1,charindex(' ',date_time)-1),120),120)+substring(date_time,charindex(' ',date_time)+1,len(date_time)),120)),'byte') total_files_size,
substring(output_text, charindex(' ', output_text)+1, len(output_text)) backup_file
from (
select ltrim(rtrim(substring(output_text, 1, charindex('M ', output_text)-2))) date_time,
ltrim(rtrim(substring(output_text, charindex('M ', output_text)+2, len(output_text)))) output_text
from @output
where output_text like '%M %'
and output_text not like '%<DIR>%')a)b
--where Creation_Date = '2023-07-20 03:00:00.000'
--order by cast(replace(substring(output_text, 1, charindex(' ', output_text)-1),',','') as bigint) desc
group by Creation_Date, total_files_size
order by creation_date desc


--exec xp_cmdshell 'del "\\npci2.d2fs.albilad.com\DBTEMP\T24DBXtremIOT3\T24_support\FULL\T24DBXTREMIOT3_T24_support_FULL_20230521_02_30_PM.bak"'

