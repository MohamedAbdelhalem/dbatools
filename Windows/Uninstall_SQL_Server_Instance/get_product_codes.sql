--print out the result of the 
--powershell.exe cd c:\temp
--.\msiinv.exe -s | select-string "SQL Server" -context 1,1
--or add the result into a text file then copy it into @sql variable
--.\msiinv.exe -s | select-string "SQL Server" -context 1,1 > c:\temp\sql.txt

declare @sql varchar(max) = '

  
> SQL Server 2017 Integration Services Scale Out Management Portal
  	Product code:	{6BD8D100-B16C-409E-B0EA-BF508D7874EC}
  
> SQL Server 2017 Shared Management Objects Extensions
  	Product code:	{C6D92730-3EC0-47B1-8F6C-6F5635D1EFAC}
  
> SQL Server 2016 Client Tools
  	Product code:	{9478E350-F157-4724-AE17-6ADA0E9E2351}
  
> Microsoft SQL Server 2016 T-SQL ScriptDom 
  	Product code:	{04B6A580-A5C5-4F8B-BC64-CFC65781C731}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update 
Cache\KB5003279\ServicePack\1033_ENU_LP\x64\setup\x64\
  	    Package:	sqldom.msi
  
> SQL Server 2016 Database Engine Shared
  	Product code:	{686A81C0-C8E4-46F6-952F-B19A28E8C430}
  
> SQL Server 2017 Batch Parser
  	Product code:	{2C6E8311-28BD-4615-9545-6E39E8E83A4B}
  
> SQL Server 2017 Shared Management Objects Extensions
  	Product code:	{8C515C22-BE07-4908-985C-0AA9349E1ED4}
  
> SQL Server 2017 Client Tools Extensions
  	Product code:	{200F38B2-1492-4576-B08C-78F2C2C953FC}
  
> SQL Server 2017 DMF
  	Product code:	{B9998A13-5563-496C-B95E-597FFC70B670}
  
> SQL Server 2016 Documentation Components
  	Product code:	{ADECAE23-1F38-49B3-8752-C89B1EE4E97B}
  
> SQL Server 2017 Integration Services Scale Out Management Portal
  	Product code:	{91C5EE43-29D1-4720-AB65-5E2E0FE25990}
  
> SQL Server 2016 Database Engine Shared
  	Product code:	{81CABA93-27C0-4BD9-9B5E-227C76B59F46}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{0C457EC3-E998-4041-B856-908D5A2C1708}
  
> Microsoft SQL Server 2017 T-SQL Language Service 
  	Product code:	{BC247FE3-C61A-4678-86C6-15408F272D57}
  
> Microsoft SQL Server 2008 Setup Support Files 
  	Product code:	{6292D514-17A4-403F-98F9-E150F10C043D}
  
> SQL Server 2017 Shared Management Objects
  	Product code:	{6CBBF624-696C-499E-948D-ADBAFFA2F548}
  
> Microsoft VSS Writer for SQL Server 2016
  	Product code:	{3E013EB4-FF9E-4CCA-BAB6-318932614FAE}
  
> Microsoft System CLR Types for SQL Server 2017
  	Product code:	{9D78F5D4-79D2-4FC6-AC56-F364A0ABC54F}
  
> Microsoft ODBC Driver 13 for SQL Server
  	Product code:	{76CF9EF4-ABA0-484E-8042-12B99499AF5F}
  
> SQL Server 2017 Management Studio Extensions
  	Product code:	{70C24F35-7E36-45FC-B289-3D2849E5556B}
  
> SQL Server Management Studio for Reporting Services
  	Product code:	{4DDEB555-26D2-4E68-98AF-8F96232C13F2}
  
> Active Directory Authentication Library for SQL Server
  	Product code:	{4EE99065-01C6-49DD-9EC6-E08AA5B13491}
  
> Microsoft System CLR Types for SQL Server 2014
  	Product code:	{718FFB65-F6E4-4D62-861F-ED10ED32C936}
  
> SQL Server 2016 Full text search
  	Product code:	{F5F6BD75-069B-4036-BC02-31CEDD72D74E}
  
> Browser for SQL Server 2016
  	Product code:	{5B860485-0F07-41DC-BA8C-3A839A141FBA}
  
> SQL Server 2017 Connection Info
  	Product code:	{A9A443F5-56E1-4FC6-937C-5F481345A843}
  
> SQL Server 2017 SQL Diagnostics
  	Product code:	{DFA6A906-3024-49DE-87AD-750EAED2FA49}
  
> SQL Server 2016 Full text search
  	Product code:	{8E331916-3F23-4146-8936-FB4EF1FD2D8B}
  
> SQL Server 2017 Management Studio Extensions
  	Product code:	{6492E746-1C5D-48C2-A92A-97D431F74664}
  
> SQL Server Management Studio
  	Product code:	{1B8CFC46-1F08-4DA7-9FEA-E1F523FBD67F}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{0CF485A6-6486-4E5A-B1B8-A32EF067DB05}
  
> Microsoft SQL Server 2016 Setup (English)
  	Product code:	{8E9727A6-2348-4D4E-967B-D5DD00F18C0E}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update 
Cache\KB5029186\GDR\1033_ENU_LP\x64\setup\sqlsupport_msi\
  	    Package:	SQLSUPPORT.MSI
  
> Microsoft SQL Server Data-Tier Application Framework (x86)
  	Product code:	{F45421F6-76C3-47EE-8823-7D064A77E1F0}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{863E9807-97F0-417A-9957-DE4372A13404}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{DB570D37-60D8-4D12-A7AB-11482EA5FE8A}
  
> SQL Server 2016 DMF
  	Product code:	{2FFF0757-4360-42F5-8814-16BB5CF0145F}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{2CE39A67-8A43-4C5C-B9F9-E587CACF80D4}
  
> SQL Server Management Studio for Analysis Services
  	Product code:	{CC6997A7-1638-4E38-B6CF-E776997036B0}
  
> SQL Server 2016 Client Tools Extensions
  	Product code:	{AB765DC7-7642-4D1C-BEDC-035516CCD224}
  
> SQL Server 2016 Connection Info
  	Product code:	{5043CE58-6AAF-488C-AC2A-A405FFF85B57}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update 
Cache\KB4052908\ServicePack\1033_ENU_LP\x64\setup\
  	    Package:	conn_info_loc.msi
  
> SQL Server 2016 Shared Management Objects
  	Product code:	{FD25FD68-9EAF-425C-BEBD-A03DBE3AA69A}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update Cache\KB5000645\QFE\x64\setup\
  	    Package:	SMO.MSI
  
> SQL Server 2016 Common Files
  	Product code:	{57846DA8-8B5D-4466-B850-E8CDFC94046C}
  
> SQL Server 2016 Connection Info
  	Product code:	{6EE546C8-37CE-47FA-9BED-9EB3CB79E8CA}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update 
Cache\KB4052908\ServicePack\x64\setup\
  	    Package:	conn_info.msi
  
> SQL Server 2016 Shared Management Objects
  	Product code:	{B3A1AD49-ECB8-45B1-91F3-99583F2E310E}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update 
Cache\KB5003279\ServicePack\1033_ENU_LP\x64\setup\
  	    Package:	smo_loc.msi
  
> Microsoft SQL Server 2017 Policies 
  	Product code:	{256EDCB9-A64D-433C-A1DC-C76F02475915}
  
> SQL Server 2017 Shared Management Objects
  	Product code:	{10855B1A-F7F2-4D8A-A725-9287C73BED5A}
  
> Sql Server Customer Experience Improvement Program
  	Product code:	{0D9BD39A-A870-4FDF-B590-1E9787CF16D9}
  
> SQL Server 2017 Common Files
  	Product code:	{6CE9A8AA-C478-4706-BD28-95993D52B5A1}
  
> SQL Server 2016 Shared Management Objects Extensions
  	Product code:	{FA548BCB-5732-40F8-85B0-61515D18D9C1}
  
> SQL Server 2016 Batch Parser
  	Product code:	{D7A905DB-9A1E-4670-9488-F979F8A77A58}
  
> SQL Server 2016 Shared Management Objects Extensions
  	Product code:	{B6E1A5EB-1C58-4A04-B76B-E5FE1BE22CA1}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{51574D2C-DE28-4441-BDC2-967F0FFC0918}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{6FA9813C-79F8-4DA3-89DE-9619470EB173}
  
> SQL Server 2016 Client Tools
  	Product code:	{A070F2AC-A75B-448C-BECB-B794EB7E0E0D}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{050B443D-9AEB-4847-B92A-E7DD886DCFE1}
  
> SQL Server 2017 Common Files
  	Product code:	{D17B5D3D-3BC7-4AFA-AD90-600B5453826E}
  
> SQL Server Management Studio
  	Product code:	{F8ADD24D-F2F2-465C-A675-F12FDB70DB82}
  
> SQL Server 2017 Client Tools Extensions
  	Product code:	{06324A5D-66BB-4FAC-8D0B-9FEC1B230FFF}
  
> SQL Server 2016 Documentation Components
  	Product code:	{2DF3556D-8F7D-4E7B-B412-1273ABF94624}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{3ABB656D-84FE-4EA8-9549-5BA43A73DB95}
  
> SQL Server 2016 Documentation Components
  	Product code:	{060F438D-A367-4B23-9487-7431025E0F87}
  
> SQL Server 2016 Database Engine Services
  	Product code:	{9CB25DAD-B089-4861-8443-4D43B1C320CA}
  
> Microsoft SQL Server 2016 RsFx Driver
  	Product code:	{872AD2BD-1051-4BDA-ACA4-74EF1F26F908}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update Cache\KB5029186\GDR\x64\setup\
  	    Package:	RSFX.MSI
  
> Microsoft SQL Server 2016 T-SQL Language Service 
  	Product code:	{FE3BF1DD-677E-4793-9770-C07AECC88882}
  
> SQL Server 2016 SQL Diagnostics
  	Product code:	{766BE25E-D2B5-4E76-BCB0-29B801BADB3F}
  
> SQL Server 2016 XEvent
  	Product code:	{8CF2CA8E-3984-46B9-B493-F844F3774FA1}
  
> SQL Server 2016 DMF
  	Product code:	{34A20DEE-6AD4-44A6-95FF-DFF95CD22B8C}
  
> SQL Server 2016 Client Tools Extensions
  	Product code:	{7E94713F-EF30-46EB-B809-BBA8603FBF9E}
  
> SQL Server 2017 Connection Info
  	Product code:	{89A7644F-E056-4EC1-BFDE-9D1A531D6855}
  
> SQL Server 2016 Common Files
  	Product code:	{16F3645F-1343-4462-92DC-9AE66A2E68A3}
  
> Microsoft SQL Server 2014 Management Objects 
  	Product code:	{2774595F-BC2A-4B12-A25B-0C37A37049B0}
  
> SQL Server 2016 Full text search
  	Product code:	{BC9BA95F-9156-409B-B033-6E115A4D8CA2}
  
> SQL Server 2016 XEvent
  	Product code:	{E6FFAAAF-D8B5-4D46-8514-26E96D9F3D8D}
  
> SQL Server 2017 DMF
  	Product code:	{D7D28BBF-3B0E-43F0-A457-331F1CD9E9EB}
  	Language:	1033
> 	Installed from: C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Update 
Cache\KB4052908\ServicePack\x64\setup\
  	    Package:	sql_as_adomd.msi
  
> Microsoft SQL Server 2012 Native Client 
  	Product code:	{4D2C56FF-7F36-4B49-A97A-24F0522D41D7}



'
declare @select_version int = 2016
declare @select_product varchar(1000) = 'Engine Services'
if (select count(*) from master.dbo.separator(@sql, char(10))) = 1
begin
select 1
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
select 2
select row_number() over(order by product_version desc, product_name) id, 
product_name, 
replace(replace(replace(replace(convert(varbinary(max),cast(product_code as nvarchar(1000))),0x0900,N''),0x0D00,N''),'}',''),'{','') product_code, product_version,
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
