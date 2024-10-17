--generate partition function and scheme for int range clustered index key column
set nocount on
declare @bulk int = 1000
declare @table table (id int identity(1,1), dataValues int)
declare @min_value int, @max_value int, @sql varchar(max)
select 
@min_value = min(SalesOrderID),
@max_value = max(SalesOrderID)
from Sales.SalesOrderHeader

select @min_value, @max_value

while @min_value < (@max_value - (@bulk *2))
begin 
insert into @table (dataValues)
select @min_value + @bulk
set @min_value += @bulk
end

select @sql = isnull(@sql+',','') + cast(dataValues as varchar(20))
from @table
order by id

print('CREATE PARTITION FUNCTION [PARTITION_F_SALES_ORDER_ID_LEFT](INT)
AS
RANGE LEFT FOR VALUES (
'+@sql+'
);')

set @sql = null
select @sql = isnull(@sql+',','') + '[PRIMARY]'
from @table
order by id

set @sql = @sql + ',[PRIMARY]'

print('GO')

print('CREATE PARTITION SCHEME [PARTITION_S_SALES_ORDER_ID]
AS PARTITION [PARTITION_F_SALES_ORDER_ID_LEFT]
TO
(
'+@sql+'
);')
set nocount off


DROP PARTITION SCHEME [PARTITION_S_SALES_ORDER_ID]
go
DROP PARTITION FUNCTION [PARTITION_F_SALES_ORDER_ID_LEFT]
go

CREATE PARTITION FUNCTION [PARTITION_F_SALES_ORDER_ID_LEFT](INT)
AS
RANGE LEFT FOR VALUES (
44659,45659,46659,47659,48659,49659,50659,51659,52659,53659,54659,55659,56659,57659,58659,59659,60659,61659,62659,63659,64659,65659,66659,67659,68659,69659,70659,71659,72659,73659
);
GO
CREATE PARTITION SCHEME [PARTITION_S_SALES_ORDER_ID]
AS PARTITION [PARTITION_F_SALES_ORDER_ID_LEFT]
TO
(
[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY]
);

select * 
from [dbo].[Foreign_Key_Create_Script]
where reference_table_name = 'SalesOrderHeader'
and primary_key_column_name = 'SalesOrderID'

Alter Table SalesOrderDetail Add Constraint FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID Foreign Key (SalesOrderID) References SalesOrderHeader (SalesOrderID)
Alter Table SalesOrderHeaderSalesReason Add Constraint FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID Foreign Key (SalesOrderID) References SalesOrderHeader (SalesOrderID)

select * from [dbo].[Foreign_Key_Drop_Script]
where reference_table_name = 'SalesOrderHeader'
and primary_key_column_name = 'SalesOrderID'

--drop the foreign keys that related to this primary key
Alter Table sales.SalesOrderDetail Drop Constraint FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID
Alter Table sales.SalesOrderHeaderSalesReason Drop Constraint FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID

--drop the primary key non-partitioned
ALTER TABLE [Sales].[SalesOrderHeader] DROP CONSTRAINT [PK_SalesOrderHeader_SalesOrderID]; 

--recreate the primary key clusterd index with online on the partition scheme [PARTITION_S_SALES_ORDER_ID] ([SalesOrderID])
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED ([SalesOrderID]) WITH (ONLINE=ON, FILLFACTOR = 100) ON [PARTITION_S_SALES_ORDER_ID] ([SalesOrderID]);

--recreate the foreign keys again
Alter Table sales.SalesOrderDetail Add Constraint FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID Foreign Key (SalesOrderID) References sales.SalesOrderHeader (SalesOrderID)
Alter Table sales.SalesOrderHeaderSalesReason Add Constraint FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID Foreign Key (SalesOrderID) References sales.SalesOrderHeader (SalesOrderID)

--CHECK THE TABLE AFTER ALTERING IT ABOUT IDENTITY TO ADD MORE ROWS
exec [dbo].[sp_table_syntax] @table_name_with_scheme = 'sales.SalesOrderHeader'
exec sp_table_indexes 'sales.SalesOrderHeader'

--to test split range
INSERT INTO [Sales].[SalesOrderHeader] 
(
[RevisionNumber], [OrderDate], [DueDate], [ShipDate], [Status], [OnlineOrderFlag], [PurchaseOrderNumber], [AccountNumber], [CustomerID], [SalesPersonID], [TerritoryID], [BillToAddressID], [ShipToAddressID], [ShipMethodID], [CreditCardID], [CreditCardApprovalCode], [CurrencyRateID], [SubTotal], [TaxAmt], [Freight], [Comment], [ModifiedDate]
)
SELECT 
[RevisionNumber], [OrderDate], [DueDate], [ShipDate], [Status], [OnlineOrderFlag], [PurchaseOrderNumber], [AccountNumber], [CustomerID], [SalesPersonID], [TerritoryID], [BillToAddressID], [ShipToAddressID], [ShipMethodID], [CreditCardID], [CreditCardApprovalCode], [CurrencyRateID], [SubTotal], [TaxAmt], [Freight], [Comment], [ModifiedDate]
FROM [Sales].[SalesOrderHeader] 
