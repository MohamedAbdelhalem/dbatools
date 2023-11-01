--node 4
:CONNECT 10.33.102.17

USE [T24Prod]
GO
select [T24Prod].dbo.tafjfield('139520068644433.010001','.','1', '-2147483648') "HISTORY_ID"

go
ALTER AUTHORIZATION ON DATABASE::[T24Prod] TO [BankSA]
GO
use master
go
alter database [T24Prod] set trustworthy on
go
exec sp_configure 'clr', 1
go
reconfigure with override
go

select [T24Prod].dbo.tafjfield('139520068644433.010001','.','1', '-2147483648') "HISTORY_ID"
