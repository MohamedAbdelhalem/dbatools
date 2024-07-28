--print out the result of the 
--powershell.exe cd c:\temp
--.\msiinv.exe -s | select-string "SQL Server" -context 1,1
--or add the result into a text file then copy it into @sql variable
--.\msiinv.exe -s | select-string "SQL Server" -context 1,1 > c:\temp\sql.txt

declare @sql varchar(max) = '

  
> SQL Server Integration Services Singleton
  	Product code:	{461966B0-AD82-42BE-8B8E-8C43380A88A9}
  
> SQL Server 2022 Shared Management Objects
  	Product code:	{12618131-AA9A-4DAE-9387-CE4417955B9F}
  
> SQL Server 2019 Data quality client
  	Product code:	{98848041-9B15-4FC9-B8AD-F93EC92730AB}
  
> Microsoft SQL Server 2019 T-SQL Language Service 
  	Product code:	{31D27B41-A051-49D8-907A-62E0F4A2188C}
  
> SQL Server 2019 Data quality service
  	Product code:	{9CF25281-9022-4E1F-83EA-7FE7C82068CB}
  
> SQL Server Integration Services Singleton
  	Product code:	{BC7E7CD1-8B30-4BF1-B7F8-D7E14CD0F404}
  
> SQL Server 2019 Client Tools Extensions
  	Product code:	{DF21FF12-F208-4012-92A1-CB7420A75FFE}
  
> SQL Server 2022 Connection Info
  	Product code:	{EAC54B82-7A37-4A9E-8953-474316BD40F6}
  
> SQL Server 2019 XEvent
  	Product code:	{228C3DC2-695E-4FC7-87E4-6A9CE905DA9B}
  
> SQL Server 2022 Connection Info
  	Product code:	{770DA7F2-817B-4AA6-9160-08BB658ABDC6}
  
> SQL Server 2019 Connection Info
  	Product code:	{FD730873-33D1-4D1F-9AE0-E259586F8827}
  
> SQL Server 2019 DMF
  	Product code:	{FC8DC283-4A85-467F-8D0E-2FE4606DCCA1}
  
> SQL Server 2019 Client Tools
  	Product code:	{68B843D3-5C31-4F0C-B61C-662C97FDAD1C}
  
> SQL Server Integration Services 2016
  	Product code:	{454E4664-1784-4DF6-B45D-25CFCFD226B4}
  
> SQL Server 2019 SQL Data Quality Common
  	Product code:	{DE61B584-A1E5-4AB4-810B-EC2F8C106B00}
  
> Microsoft SQL Server 2019 RsFx Driver
  	Product code:	{5825CDC4-4E99-4CF9-91FE-DB60C0E2F5EA}
  
> SQL Server 2019 Client Tools Extensions
  	Product code:	{EA0ADED4-831D-45B3-B612-C7FD0A1E2BAB}
  
> SQL Server 2022 Shared Management Objects Extensions
  	Product code:	{35EC6145-E333-42DB-BCB3-380DF6140C11}
  
> SQL Server 2019 Data quality client
  	Product code:	{089D4965-E3F7-4712-98AB-FA612518F81E}
  
> SQL Server 2019 Connection Info
  	Product code:	{99B940D5-1A49-4B6C-B26C-6A88B2C061CA}
  
> Browser for SQL Server 2022
  	Product code:	{FDB357D5-CC78-480A-8D26-C15D1A877642}
  
> SQL Server 2019 Client Tools
  	Product code:	{9F3D48F5-4184-444C-A810-845C6F078721}
  
> SQL Server 2022 DMF
  	Product code:	{DCA0C2D6-83BF-41AE-B1AB-C4181002DE40}
  
> SQL Server 2019 Database Engine Shared
  	Product code:	{DE5B7937-D5B5-4157-BC30-BB87F021CFF0}
  
> Microsoft SQL Server 2012 Native Client 
  	Product code:	{9D93D367-A2CC-4378-BD63-79EF3FE76C78}
  
> SQL Server 2019 DMF
  	Product code:	{814D5077-C93F-42E2-B875-717007C186B9}
  
> SQL Server 2019 Shared Management Objects Extensions
  	Product code:	{C7E6D4B7-CB10-4239-BA04-D9339B39D0BD}
  
> Microsoft Command Line Utilities 15 for SQL Server
  	Product code:	{41C0DB18-1790-465E-B0DD-D9CAA35CACBE}
  
> SQL Server 2019 SQL Diagnostics
  	Product code:	{28ED6838-D8E5-454C-A813-12C5EB447CAB}
  
> SQL Server 2022 SQL Diagnostics
  	Product code:	{0CEFE958-E71A-4171-9DEF-77E9234A5613}
  
> SQL Server Integration Services Singleton
  	Product code:	{98D54C58-4AE3-4B54-BD8F-31E237BF60C2}
  
> Microsoft VSS Writer for SQL Server 2022
  	Product code:	{AB5D8778-81F3-47E2-87A4-35E776CD664B}
  
> Microsoft SQL Server 2019 LocalDB 
  	Product code:	{36E492B8-CB83-4DA5-A5D2-D99A8E8228A1}
  
> SQL Server 2022 Batch Parser
  	Product code:	{7EFD8B19-A9E6-41CF-A96F-B9B6E30EC345}
  
> Microsoft OLE DB Driver for SQL Server
  	Product code:	{5331C869-DED5-43C3-945A-8AE2EE347654}
  
> SQL Server 2019 Shared Management Objects
  	Product code:	{A8581199-F913-443B-B058-8E8BF317E71C}
  
> SQL Server 2019 Common Files
  	Product code:	{5E4344C9-8B97-4ED9-8760-57E221C240F4}
  
> SQL Server 2022 Shared Management Objects
  	Product code:	{6F8242AA-1B25-421C-8E45-FC5978D9AA3A}
  
> SQL Server 2022 Shared Management Objects Extensions
  	Product code:	{A0F7ACBA-075F-4BC7-A85A-5DC301FCEC74}
  
> SQL Server 2019 Shared Management Objects Extensions
  	Product code:	{8DDAEBCA-4267-4E16-9FE0-D87F21D36891}
  
> Microsoft AS OLE DB Provider for SQL Server 2016
  	Product code:	{C49E181B-C19F-4A1F-BE76-D463E7E3B2B5}
  
> SQL Server 2019 Batch Parser
  	Product code:	{D459615B-83B0-408F-8F39-6CC07C277BA6}
  
> SQL Server 2019 Shared Management Objects
  	Product code:	{6213D6CB-D258-47A3-B1A0-EE1E5C080DCF}
  
> Microsoft System CLR Types for SQL Server 2019
  	Product code:	{5BC7E9EB-13E8-45DB-8A60-F2481FEB4595}
  
> SQL Server 2019 Data quality service
  	Product code:	{D279840C-4BD6-47E1-8A2E-47E69CD8A863}
  
> SQL Server 2019 Database Engine Services
  	Product code:	{E3E84B2C-FCF6-469F-9FE7-5E8934DB69AD}
  
> SQL Server Management Studio Language Pack - English
  	Product code:	{F203903C-AAB3-4DA5-8193-864844BE3141}
  
> SQL Server 2019 Integration Services
  	Product code:	{3551AA5C-0DF4-47E6-A144-EA97E2AAAFC9}
  
> SQL Server 2019 Database Engine Shared
  	Product code:	{619F0B6C-C802-422A-B4E5-294E61F68473}
  
> Microsoft ODBC Driver 17 for SQL Server
  	Product code:	{0E0F96AC-80DE-4400-A40C-429D63293651}
  
> SQL Server 2019 Integration Services
  	Product code:	{BEB4DA4D-7186-4FA6-8563-3EA3F007FBC0}
  
> Microsoft SQL Server 2016 Analysis Management Objects 
  	Product code:	{97A881AD-5134-4CD2-A6A8-371C83E5622B}
  
> SQL Server 2019 Common Files
  	Product code:	{0FB552DD-543E-48E7-A6F4-2F8D82723C6A}
  
> Microsoft SQL Server 2019 Setup (English)
  	Product code:	{17DCED0E-5B27-453A-B2B4-E487B869B28A}
  
> SQL Server 2019 XEvent
  	Product code:	{2129312E-5204-4F3A-9039-B6D34DBB00FB}
  
> SQL Server 2022 DMF
  	Product code:	{5AB77D4E-9E5F-4627-B78B-129A5EC2858A}
  
> SQL Server Management Studio
  	Product code:	{9E497A7E-26BE-4BA3-AF58-071D8D700DA7}
  
> SQL Server 2019 Database Engine Services
  	Product code:	{A60B3D8E-5311-4BF1-AF7A-D1AC15F9152E}




'
select row_number() over(order by product_version desc, product_name) id, product_name, product_code, product_version,
'msiexec /x "'+replace(replace(convert(varbinary(max),cast(product_code as nvarchar(1000))),0x0900,N''),0x0D00,N'')+'"'
from (
select gbulk id, 
ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) product_name, 
ltrim(rtrim(substring([2], charindex(':',[2])+1,len([2])))) product_code,
case 
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2008%' then 2008
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2012%' then 2012
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2014%' then 2014
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2016%' then 2016
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2017%' then 2017
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2019%' then 2019
when ltrim(rtrim(substring([1], charindex('>',[1])+1,len([1])))) like '%2022%' then 2022
end product_version
from (
select row_number() over(partition by gbulk order by id)row_id, gbulk, value 
from (
select top 100 percent master.dbo.gBulk(row_number() over(order by id),2) gbulk, id, value 
from master.dbo.separator(@sql, char(10))
where value like '%>%'
or value like '%Product%'
order by id)a)b
pivot (
max(value) for row_id in ([1],[2]))p)c
where product_version = 2022
order by product_version desc, product_name
