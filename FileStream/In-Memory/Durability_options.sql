alter database [adventureworks2019] add filegroup fg_memory_optimizer CONTAINS MEMORY_OPTIMIZED_DATA
GO

alter database [adventureworks2019] add file (name='IN_MEM_OPTZD__01', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\IN_MEM_OPTZD__01') to filegroup fg_memory_optimizer
GO

CREATE TABLE dbo.Temp_MOP
(
    Id INT NOT NULL INDEX ix1 NONCLUSTERED,
    Name NVARCHAR(4000)
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY);
GO

Insert into dbo.Temp_MOP values (1124, 'Mohamed Fawzy Ismail Abdelhalem')
GO

CREATE TABLE dbo.OTP
(
	Id INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    mobile BIGINT NOT NULL INDEX IX_mobile_OTP NONCLUSTERED,
    OTP_Number INT NOT NULL,
	sendDate datetime default getdate()
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

Insert into dbo.OTP (mobile, OTP_Number) values (966532934184, 12345)
GO

select * from dbo.Temp_MOP
select * from dbo.OTP

--restart your instance and you will see that the data on dbo.Temp_MOP does not presist on the table rather than dbo.OTP
