create table [Sales].[ProtectedData04](
id                  int identity(1,1), 
description_text    nvarchar(100), 
value               varbinary(max))

DROP SYMMETRIC KEY SYMMohamed
go
CREATE SYMMETRIC KEY SYMMohamed   
WITH ALGORITHM = AES_256 
ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'; 
go

select * 
from sys.symmetric_keys
go

open symmetric key SYMMohamed
decryption by password = 'pGFD4bb925DGvbd2439587y'

declare 
@text nvarchar(max) = N'I am starting to research setting up log shipping with our server. I am thinking I want to use standby mode for the remote server for the things I want to do (Data checks, ect.) What I wanted to know and have not been able to really find a definite answer on is once I create a undo file with the standby mode of restoring the database,'

insert into AdventureWorks2019.Sales.ProtectedData04 values( 
N'SYMMohamed',  
EncryptByKey(key_guid('SYMMohamed'), @text))

close symmetric key SYMMohamed

go

open symmetric key SYMMohamed
decryption by password = 'pGFD4bb925DGvbd2439587y'

select convert(nvarchar(max),DECRYPTBYKEY(value)) value
from [AdventureWorks2019].[Sales].[ProtectedData04]   

close symmetric key SYMMohamed

go

drop table [Sales].[ProtectedData04]
