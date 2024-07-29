--print out the result of the 
--powershell.exe cd c:\temp
--.\msiinv.exe -s | select-string "SQL Server" -context 1,1
--or add the result into a text file then copy it into @sql variable
--.\msiinv.exe -s | select-string "SQL Server" -context 1,1 > c:\temp\sql.txt

declare @sql varchar(max) = '

  
> SQL Server 2017 Integration Services Scale Out Management Portal
      Product code:    {6BD8D100-B16C-409E-B0EA-BF508D7874EC}
  
> SQL Server 2017 Shared Management Objects Extensions
      Product code:    {C6D92730-3EC0-47B1-8F6C-6F5635D1EFAC}
  
> SQL Server 2016 Client Tools
      Product code:    {9478E350-F157-4724-AE17-6ADA0E9E2351}
  
> SQL Server 2016 Database Engine Shared
      Product code:    {686A81C0-C8E4-46F6-952F-B19A28E8C430}
  
> SQL Server 2017 Common Files
      Product code:    {B777C4C0-A1CD-4AB9-99B1-AD5FBED6F8E5}
  
> SQL Server Management Studio for Analysis Services
      Product code:    {A1CAC3E0-B321-40FE-8907-4739297D5338}
  
> SQL Server 2016 Connection Info
      Product code:    {8A3AE1F0-0752-435D-A01C-033BDD629C8B}
  
> SQL Server 2017 Batch Parser
      Product code:    {2C6E8311-28BD-4615-9545-6E39E8E83A4B}
  
> SQL Server 2016 Shared Management Objects
      Product code:    {F8001E21-CFCC-47AD-A3B1-6B3EB6D35E48}
  
> SQL Server 2016 Shared Management Objects
      Product code:    {D3FC7A31-F127-4E2A-96F6-B24FA7D3FFAF}
  
> SQL Server Management Studio
      Product code:    {00BE2F31-85B3-414F-8BAD-01E24FB17541}
  
> SQL Server 2017 Client Tools
      Product code:    {A6A9EFA1-AFEB-4209-B25D-3CFF2E6FAE2C}
  
> SQL Server 2017 Client Tools
      Product code:    {BD1502B1-778B-44B6-B2B4-0B77BD0366A1}
  
> SQL Server 2016 Data quality client
      Product code:    {51B449C1-3374-4009-B9E2-2D4D02C33B2A}
  
> SQL Server 2017 Shared Management Objects Extensions
      Product code:    {8C515C22-BE07-4908-985C-0AA9349E1ED4}
  
> SQL Server Management Studio for Reporting Services
      Product code:    {E1546272-52E8-4D3D-8129-3DDB3CC3B487}
  
> SQL Server 2017 Client Tools Extensions
      Product code:    {200F38B2-1492-4576-B08C-78F2C2C953FC}
  
> SQL Server 2017 DMF
      Product code:    {B9998A13-5563-496C-B95E-597FFC70B670}
  
> SQL Server 2016 Documentation Components
      Product code:    {ADECAE23-1F38-49B3-8752-C89B1EE4E97B}
  
> SQL Server 2017 Integration Services Scale Out Management Portal
      Product code:    {91C5EE43-29D1-4720-AB65-5E2E0FE25990}
  
> Microsoft SQL Server 2017 T-SQL Language Service 
      Product code:    {C8A51693-98B9-4AB1-91B8-9A1B86729D5F}
  
> SQL Server 2016 Database Engine Shared
      Product code:    {81CABA93-27C0-4BD9-9B5E-227C76B59F46}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_01
      Product code:    {0C457EC3-E998-4041-B856-908D5A2C1708}
  
> Microsoft SQL Server 2008 Setup Support Files 
      Product code:    {6292D514-17A4-403F-98F9-E150F10C043D}
  
> SQL Server 2017 Shared Management Objects
      Product code:    {6CBBF624-696C-499E-948D-ADBAFFA2F548}
  
> Microsoft OLE DB Driver for SQL Server
      Product code:    {9D6F8754-28E9-4940-B319-3FC8588CF18F}
  
> SQL Server 2016 Data quality client
      Product code:    {0C41EB54-B85C-4090-9EB7-03D54C80F8BC}
  
> SQL Server 2017 Database Engine Shared
      Product code:    {0E22DBB4-691B-400C-B52D-8DFE8EC421AA}
  
> Microsoft System CLR Types for SQL Server 2017
      Product code:    {9D78F5D4-79D2-4FC6-AC56-F364A0ABC54F}
  
> Microsoft ODBC Driver 13 for SQL Server
      Product code:    {76CF9EF4-ABA0-484E-8042-12B99499AF5F}
  
> SQL Server 2017 Data quality client
      Product code:    {AA85B815-781C-4233-98F2-A4417D839DD7}
  
> SQL Server 2016 SQL Data Quality Common
      Product code:    {78281525-26B5-48E0-AB36-DFEE117D96BA}
  
> Active Directory Authentication Library for SQL Server
      Product code:    {4EE99065-01C6-49DD-9EC6-E08AA5B13491}
  
> Microsoft System CLR Types for SQL Server 2014
      Product code:    {718FFB65-F6E4-4D62-861F-ED10ED32C936}
  
> SQL Server 2016 Connection Info
      Product code:    {74940EE5-66DB-42E3-AC30-295D13B461A7}
  
> SQL Server 2017 Connection Info
      Product code:    {A9A443F5-56E1-4FC6-937C-5F481345A843}
  
> SQL Server Management Studio for Reporting Services
      Product code:    {0278A8F5-4DDC-40FF-95CC-1D4725CA074B}
  
> SQL Server 2017 SQL Diagnostics
      Product code:    {DFA6A906-3024-49DE-87AD-750EAED2FA49}
  
> Microsoft SQL Server 2016 RsFx Driver
      Product code:    {B9E13376-B7BD-48AB-A643-67CC4A8FA607}
  
> Browser for SQL Server 2017
      Product code:    {CF8EEB96-E7E7-4EF7-A0A1-559F09953156}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_04
      Product code:    {0CF485A6-6486-4E5A-B1B8-A32EF067DB05}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_02
      Product code:    {863E9807-97F0-417A-9957-DE4372A13404}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_03
      Product code:    {DB570D37-60D8-4D12-A7AB-11482EA5FE8A}
  
> SQL Server 2017 Management Studio Extensions
      Product code:    {F094B947-8B4D-4094-B9A0-2A5281DD33B9}
  
> SQL Server 2016 DMF
      Product code:    {2FFF0757-4360-42F5-8814-16BB5CF0145F}
  
> Microsoft SQL Server 2012 Native Client 
      Product code:    {9D93D367-A2CC-4378-BD63-79EF3FE76C78}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_03
      Product code:    {2CE39A67-8A43-4C5C-B9F9-E587CACF80D4}
  
> SQL Server 2016 Client Tools Extensions
      Product code:    {AB765DC7-7642-4D1C-BEDC-035516CCD224}
  
> SQL Server 2017 Integration Services
      Product code:    {03066218-5DDD-441C-A3BD-0D008D1B1A74}
  
> Microsoft SQL Server Data-Tier Application Framework (x86)
      Product code:    {8074FE78-BDB1-4E15-B525-E73C95F4328D}
  
> SQL Server 2017 Management Studio Extensions
      Product code:    {6551F688-1EDC-4A05-B216-1F3A8E26384F}
  
> SQL Server 2016 Common Files
      Product code:    {57846DA8-8B5D-4466-B850-E8CDFC94046C}
  
> SQL Server 2017 Common Files
      Product code:    {9D1C0509-D490-4E9E-ACF5-A73E5C53742D}
  
> SQL Server Management Studio
      Product code:    {C1350829-89AE-4566-ADF6-E7587D0C6B78}
  
> SQL Server Management Studio for Analysis Services
      Product code:    {6E76BF79-B025-467B-97D7-65CA8E6785EA}
  
> SQL Server Management Studio
      Product code:    {A401EAB9-4FC7-4F0C-8D79-9575E4910FDE}
  
> Microsoft SQL Server 2017 Policies 
      Product code:    {256EDCB9-A64D-433C-A1DC-C76F02475915}
  
> Microsoft VSS Writer for SQL Server 2017
      Product code:    {20B328C9-C6BB-434A-928A-00F05CD820B8}
  
> Microsoft SQL Server 2017 T-SQL Language Service 
      Product code:    {4BE1560A-C96B-4D22-8A73-1D0DFA1C6FE2}
  
> SQL Server 2017 Shared Management Objects
      Product code:    {10855B1A-F7F2-4D8A-A725-9287C73BED5A}
  
> SQL Server 2017 Data quality client
      Product code:    {CA3EB96A-784A-4059-94B3-92F61BAF4458}
  
> Sql Server Customer Experience Improvement Program
      Product code:    {0D9BD39A-A870-4FDF-B590-1E9787CF16D9}
  
> SQL Server 2017 Common Files
      Product code:    {6CE9A8AA-C478-4706-BD28-95993D52B5A1}
  
> SQL Server 2017 Database Engine Services
      Product code:    {28EEF6BA-A23A-42D2-86BA-A6BEE723B969}
  
> SQL Server 2017 Database Engine Services
      Product code:    {DED314CA-0EFE-4593-9D66-EF75E5289A4C}
  
> Microsoft ODBC Driver 17 for SQL Server
      Product code:    {853997DA-6FCB-4FB9-918E-E0FF881FAF65}
  
> SQL Server Management Studio
      Product code:    {3F338A1B-1DCF-458F-8189-416B09B7D077}
  
> SQL Server 2016 Shared Management Objects Extensions
      Product code:    {FA548BCB-5732-40F8-85B0-61515D18D9C1}
  
> SQL Server 2016 Batch Parser
      Product code:    {D7A905DB-9A1E-4670-9488-F979F8A77A58}
  
> SQL Server 2016 Shared Management Objects Extensions
      Product code:    {B6E1A5EB-1C58-4A04-B76B-E5FE1BE22CA1}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_01
      Product code:    {51574D2C-DE28-4441-BDC2-967F0FFC0918}
  
> SQL Server 2017 XEvent
      Product code:    {AA2A015C-C210-413B-95F6-BF9D3CDD6E0D}
  
> Microsoft SQL Server 2016 T-SQL ScriptDom 
      Product code:    {D091DE8C-EA0F-49AF-8DE3-BD6C79737C6E}
  
> SQL Server 2016 Client Tools
      Product code:    {A070F2AC-A75B-448C-BECB-B794EB7E0E0D}
  
> Microsoft SQL Server 2017 Setup (English)
      Product code:    {405252DC-ADF7-4BC8-95F5-F89DE513DD62}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_04
      Product code:    {050B443D-9AEB-4847-B92A-E7DD886DCFE1}
  
> SQL Server 2017 Common Files
      Product code:    {D17B5D3D-3BC7-4AFA-AD90-600B5453826E}
  
> SQL Server 2017 Client Tools Extensions
      Product code:    {06324A5D-66BB-4FAC-8D0B-9FEC1B230FFF}
  
> SQL Server 2016 Documentation Components
      Product code:    {2DF3556D-8F7D-4E7B-B412-1273ABF94624}
  
> SQL Server 2016 Documentation Components
      Product code:    {060F438D-A367-4B23-9487-7431025E0F87}
  
> SQL Server 2017 XEvent
      Product code:    {12D2DB8D-80FF-4152-8F51-EDB3BD3C6976}
  
> SQL Server 2016 Database Engine Services - MSSQL2016_02
      Product code:    {9CB25DAD-B089-4861-8443-4D43B1C320CA}
  
> SQL Server 2017 Database Engine Shared
      Product code:    {793F1C1E-5C83-4E33-A29B-6EAA7C1E791C}
  
> SQL Server 2017 Integration Services
      Product code:    {DE14794E-7B6D-4205-B55D-A7D42CABAFEE}
  
> SQL Server 2016 SQL Diagnostics
      Product code:    {766BE25E-D2B5-4E76-BCB0-29B801BADB3F}
  
> Microsoft SQL Server 2016 Setup (English)
      Product code:    {22136C6E-D65A-4D65-9557-292E01C71D04}
  
> SQL Server 2016 XEvent
      Product code:    {8CF2CA8E-3984-46B9-B493-F844F3774FA1}
  
> SQL Server 2017 SQL Data Quality Common
      Product code:    {CC2BCB9E-24C0-4681-B2E7-80B0DBC6211E}
  
> SQL Server 2016 DMF
      Product code:    {34A20DEE-6AD4-44A6-95FF-DFF95CD22B8C}
  
> SQL Server 2016 Client Tools Extensions
      Product code:    {7E94713F-EF30-46EB-B809-BBA8603FBF9E}
  
> SQL Server 2017 Connection Info
      Product code:    {89A7644F-E056-4EC1-BFDE-9D1A531D6855}
  
> SQL Server 2016 Common Files
      Product code:    {16F3645F-1343-4462-92DC-9AE66A2E68A3}
  
> Microsoft SQL Server 2014 Management Objects 
      Product code:    {2774595F-BC2A-4B12-A25B-0C37A37049B0}
  
> Microsoft SQL Server 2017 RsFx Driver
      Product code:    {7123D29F-9197-4686-A619-C7E8EA289718}
  
> SQL Server 2016 XEvent
      Product code:    {E6FFAAAF-D8B5-4D46-8514-26E96D9F3D8D}
  
> SQL Server 2017 DMF
      Product code:    {D7D28BBF-3B0E-43F0-A457-331F1CD9E9EB}



'
declare @select_version int = 2016
declare @select_product varchar(1000) = 'Engine Services'
if (select count(*) from master.dbo.separator(@sql, char(10))) = 1
begin

select row_number() over(partition by product_name order by product_name) id, 
product_name, product_code, 
'msiexec /x "{'+replace(replace(convert(varbinary(max),cast(product_code as nvarchar(1000))),0x0900,N''),0x0D00,N'')+'}"' msiexec_delete_service, 
product_version
from (
select id, product_name, product_code, case 
when product_name like '%2008%' then 2008
when product_name like '%2012%' then 2012
when product_name like '%2014%' then 2014
when product_name like '%2016%' then 2016
when product_name like '%2017%' then 2017
when product_name like '%2019%' then 2019
when product_name like '%2022%' then 2022
else 0 end product_version
from (
select id, case when charindex('product', value) > 0 then substring(value, 1, charindex('product',value)-1) end product_name,
case when charindex('product', value) > 0 then substring(value,charindex('{',value)+1, 36) end product_code
from master.dbo.separator(@sql, '>'))a)b
where product_version = @select_version
and product_name like '%'+@select_product+'%'
order by product_name
end
else
begin

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
where product_version = @select_version
and product_name like '%'+@select_product+'%'
order by product_version desc, product_name
end
