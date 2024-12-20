### Create a Column Master Key that that will be used later to create the Column Encryption Key.

1. Click on Object Explorer, expand the AdventureWorks2022 database, 
2. expand the Security folder, 
3. expand the Always Encrypted Keys folder 
4. right-click on the `Column Master Key` folder and choose **New Column Master Key…**.
5. In the Name box, type `AE_CMK`.
6. Click `Generate` Certificate to create **a self-signed certificate** for testing purposes:
7. The new certificate is a self-signed certificate and it will have an "Issued To" value of Always Encrypted Certificate. Highlight the newly created certificate and click OK.
8. Create a Column Encryption Key that will be used to encrypt the columns we choose.
9. Right-click on the `Column Encryption Key` folder and choose **New Column Encryption Key…**.
10. In the New Column Encryption Key window, enter `AE_CEK` in the Name box and select `AE_CMK` from the Column master key drop-down list.
11. Click on the OK button when finished.
12. Create a table with Always Encrypted Column protecting two columns.

```SQL
USE Adventureworks2022

DROP TABLE IF EXISTS Patients 
CREATE TABLE dbo.Patients
(
    PatientID int identity primary key,
    LastName NVARCHAR(50),
    FirstName NVARCHAR(50),
    BirthDate datetime2(7) ENCRYPTED WITH 
        (
            ENCRYPTION_TYPE = RANDOMIZED, 
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', 
            COLUMN_ENCRYPTION_KEY = AE_CEK
        ),
    SSN NVARCHAR(11) COLLATE Latin1_General_BIN2 ENCRYPTED WITH 
        (
            ENCRYPTION_TYPE = DETERMINISTIC, 
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', 
            COLUMN_ENCRYPTION_KEY = AE_CEK
        ) 
);
```

13. fill the table with this sample by executing this code

```SQL
USE Adventureworks2022
go
DROP TABLE IF EXISTS Patients 
go
CREATE TABLE dbo.Patients
(
    PatientID int identity primary key,
    LastName NVARCHAR(50),
    FirstName NVARCHAR(50),
    BirthDate datetime2(7) ENCRYPTED WITH 
        (
            ENCRYPTION_TYPE = RANDOMIZED, 
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', 
            COLUMN_ENCRYPTION_KEY = AE_CEK
        ),
    SSN NVARCHAR(11) COLLATE Latin1_General_BIN2 ENCRYPTED WITH 
        (
            ENCRYPTION_TYPE = DETERMINISTIC, 
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', 
            COLUMN_ENCRYPTION_KEY = AE_CEK
        ) 
);
go

declare @PatientID int, @LastName nvarchar(50), 
@FirstName nvarchar(50), @BirthDate datetime2, @SSN nvarchar(11)
declare @table table (PatientID int, LastName nvarchar(50), 
FirstName nvarchar(50), BirthDate datetime2, SSN nvarchar(11))
insert into @table values
(1, 'Doe', 'John', '1971-05-21', '123-45-6789'),
(2, 'Doe', 'Joahnne', '1974-12-01', '111-22-3333'),
(3, 'Park', 'Michael', '1928-11-18', '562-00-6354')

declare @sql nvarchar(max)
declare insert_cursor cursor fast_forward
for
select LastName, FirstName, BirthDate, SSN
from @table
order by PatientID

open insert_cursor
fetch next from insert_cursor into @LastName,@FirstName,@BirthDate,@SSN 
while @@FETCH_STATUS = 0
begin

set @sql = 'declare @bd datetime2 = '+''''+CONVERT(nvarchar(10),@BirthDate,120)+''''+'
declare @sn nvarchar(11) = '+''''+@SSN+''''+'
Insert into dbo.Patients (LastName,FirstName,BirthDate,SSN)
Values ('+''''+@LastName+''''+','+''''+@FirstName+''''+',@bd,@sn)'
print(@sql)
print('go')

fetch next from insert_cursor into @LastName,@FirstName,@BirthDate,@SSN 
end
close insert_cursor 
deallocate insert_cursor 
go

select * from dbo.patients
```
