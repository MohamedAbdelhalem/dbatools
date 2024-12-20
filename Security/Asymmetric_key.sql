create table [Sales].[ProtectedData04](
id                  int identity(1,1), 
description_text    nvarchar(100), 
value               varbinary(max))

DROP ASYMMETRIC KEY ASYMMohamed
go
DROP ASYMMETRIC KEY ASYMMohamed_RSA_4096
go
CREATE ASYMMETRIC KEY ASYMMohamed   
WITH ALGORITHM = RSA_2048   --max nvarchar(250)
ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'; 
go
CREATE ASYMMETRIC KEY ASYMMohamed_RSA_4096
WITH ALGORITHM = RSA_4096   --max nvarchar(122)
ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'; 
go

--RSA_2048 max nvarchar(122)
--RSA_4096 max nvarchar(250)

select * 
from sys.asymmetric_keys
go

declare 
@text nvarchar(250) = N'I am starting to research setting up log shipping with our server. I am thinking I want to use standby mode for the remote server for the things I want to do (Data checks, ect.) What I wanted to know and have not been able to really find a definite answer on is once I create a undo file with the standby mode of restoring the database,'

insert into AdventureWorks2019.Sales.ProtectedData04 values( 
N'ASYMMohamed_RSA_4096',  
EncryptByAsymKey(AsymKey_ID('ASYMMohamed_RSA_4096'), @text))

declare 
@text2 nvarchar(122) = N'I am starting to research setting up log shipping with our server. I am thinking I want to use standby mode for the remote server for the things I want to do (Data checks, ect.) What I wanted to know and have not been able to really find a definite answer on is once I create a undo file with the standby mode of restoring the database,'

insert into AdventureWorks2019.Sales.ProtectedData04 values( 
N'ASYMMohamed',  
EncryptByAsymKey(AsymKey_ID('ASYMMohamed'), @text2))
GO  

SELECT *
FROM [AdventureWorks2019].[Sales].[ProtectedData04]   

select CONVERT(NVARCHAR(max),DecryptByAsymKey( AsymKey_Id(description_text),value, N'pGFD4bb925DGvbd2439587y')) DecryptedData   
from [AdventureWorks2019].[Sales].[ProtectedData04]   
where description_text = 'ASYMMohamed_RSA_4096'

select CONVERT(NVARCHAR(max),DecryptByAsymKey( AsymKey_Id(description_text),value, N'pGFD4bb925DGvbd2439587y')) DecryptedData   
from [AdventureWorks2019].[Sales].[ProtectedData04]   
where description_text = 'ASYMMohamed'

drop table [Sales].[ProtectedData04]
