--clean garbage_collection
--connect with DAC
--###########################
--use adventureworks2019
--GO
--select * 
--from sys.objects 
--where name like '%tombstone%'

--select *, master.dbo.numbersize(size,'b') 
--from sys.filestream_tombstone_2073058421

--select master.dbo.numbersize(sum(size),'b') Garbage_size
--from sys.filestream_tombstone_2073058421

--exec sp_filestream_force_garbage_collection @dbname = 'AdventureWorks2019'
--backup Transaction log
--exec sp_filestream_force_garbage_collection @dbname = 'AdventureWorks2019'

declare 
@location	varchar(1000) = 'C:\MSSQL\Pictures_filestream\',
@cmd		varchar(1500),
@sql		varchar(max), 
@loop		int = 0
declare @table		table (output_text varchar(1000))
declare @openrowset table (NationalIDNumber nvarchar(15), photoName varchar(1000), photo varbinary(max))
declare @script		table (id int, output_text varchar(1000))

set @cmd = 'xp_cmdshell ''dir cd "'+@location+'"'+''''

insert into @table
exec(@cmd)

insert into @script
select row_number()over(order by [file_name]) id,
'select '+substring([file_name], 1, charindex('_',[file_name])-1)+','+  ''''+substring([file_name], charindex('_',[file_name])+1, len([file_name]))+''''+' photoname, '+
'* from openrowset(bulk '+''''+@location+[file_name]+''''+
', single_blob) as fd' script_text
from (
select 
ltrim(rtrim(substring(output_text, charindex(' ',output_text)+1, len(output_text)))) [file_name]
from (
select ltrim(rtrim(substring(output_text, charindex(' ',output_text)+1, len(output_text)))) output_text
from (
select substring(output_text, charindex(':',output_text)+1, len(output_text)) output_text
from @table
where output_text like '%:%'
and output_text not like '%<DIR>%'
and output_text not like '%Directory %')a)b)c

while @loop < (select count(id) from @script)
begin
set @loop += 1
select @sql = output_text 
from @script
where id = @loop

insert into @openrowset 
exec(@sql)
end

insert into [AdventureWorks2019].[HumanResources].[Employees] 
([BusinessEntityID], [NationalIDNumber], [PhotoName], [Photo], [LoginID], [OrganizationNode], [JobTitle], [BirthDate], [MaritalStatus], [Gender], [HireDate], [SalariedFlag], [VacationHours], [SickLeaveHours], [CurrentFlag], [rowguid], [ModifiedDate])
select 
a.[BusinessEntityID], a.[NationalIDNumber], b.photoName, b.photo, a.[LoginID], a.[OrganizationNode], a.[JobTitle], a.[BirthDate], a.[MaritalStatus], a.[Gender], a.[HireDate], a.[SalariedFlag], a.[VacationHours], a.[SickLeaveHours], a.[CurrentFlag], a.[rowguid], a.[ModifiedDate]
from [AdventureWorks2019].[HumanResources].[Employee] a inner join @openrowset b
on a.NationalIDNumber = b.NationalIDNumber
GO

select * from [AdventureWorks2019].[HumanResources].[Employees] 
