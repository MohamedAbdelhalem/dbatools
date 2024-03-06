CREATE TABLE [dbo].[DonationTransactions_summary](
	[id] [bigint] NOT NULL,
	[unique_id] [bigint] NULL,
	[from_id] [bigint] NULL,
	[to_id] [bigint] NULL,
	[from_unique_column] [uniqueidentifier] NULL,
	[to_unique_column] [uniqueidentifier] NULL,
	[date_time] [datetime] NULL,
	[inserted] [int] NULL,
	[deleted] [int] NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Donation_summary](
	[id] [bigint] NOT NULL,
	[unique_id] [bigint] NULL,
	[from_id] [bigint] NULL,
	[to_id] [bigint] NULL,
	[from_unique_column] [bigint] NULL,
	[to_unique_column] [bigint] NULL,
	[date_time] [datetime] NULL,
	[inserted] [int] NULL,
	[deleted] [int] NULL
) ON [PRIMARY]
GO



insert into [master].[dbo].[PreDonationTransactions_summary]
([id], [unique_id], [from_id], [to_id], [from_unique_column], [to_unique_column])
select partition_by, 1, ((partition_by -1) * 1000) + 1, (1000 * partition_by),  min(id) , max(id)--, creationTime
from (
select top 100 percent master.dbo.gBulk(row_number() over(order by id), 1000) partition_by, --convert(varchar(10),creationTime,120) 
creationTime, id
from Ehsan.dbo.PreDonationTransactions
where CreationTime < '2023-12-01'
order by id)a
--where CreationTime < '2023-12-01'
group by partition_by
order by a.partition_by

go

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_big_table_bulk_Archive_uniqueidentifier]    Script Date: 3/6/2024 4:10:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_big_table_bulk_Archive_uniqueidentifier](
@table_name			nvarchar(500) = '[Ehsan].[dbo].[DonationTransactions]', 
@arch_table_name	nvarchar(500) = '[Ehsan].[dbo].[DonationTransactions_Archive]', 
@cluster_index_key	nvarchar(300) = '[id]',
@stop_date_column	nvarchar(300) = '[CreationTime]',
@keep_months		int		= 3
)
as
begin

declare 
@summary_id						bigint,
@cluster_index_key_from 		uniqueidentifier, 
@cluster_index_key_to			uniqueidentifier,
@sql_delete						nvarchar(max),
@sql_insert						nvarchar(max),
@insert_validation				bigint,
@insert_validation_rowcount 	bigint,
@sql_validation_insert			nvarchar(max),
@till_date						datetime = dateadd(month, - @keep_months, convert(nvarchar(10),dateadd(day,-day(getdate()),getdate()) + 1,120))

--select @till_date

set nocount on
declare delete_cursor cursor fast_forward
for
select
id, 
[from_unique_column],
[to_unique_column]
from [master].[dbo].[DonationTransactions_summary]
where unique_id = 1
and inserted = 0
and deleted = 0
order by id 

open delete_cursor 
fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
while @@FETCH_STATUS = 0
begin

set @sql_insert = 'insert into '+@arch_table_name+' 
([Id], [CreationTime], [CreatorId], [LastModificationTime], [LastModifierId], [Status], [Total], [PaymentId], [GifteeMobile], [GifteeName], [IsGift], [SenderName], [IsQuickDonation], [DonationSource], [PaymentMethod], [DonationUserAgent], [MID], [BankTransId], [BankReferrerId], [ReceiptNumber], [Bank])
select 
[Id], [CreationTime], [CreatorId], [LastModificationTime], [LastModifierId], [Status], [Total], [PaymentId], [GifteeMobile], [GifteeName], [IsGift], [SenderName], [IsQuickDonation], [DonationSource], [PaymentMethod], [DonationUserAgent], [MID], [BankTransId], [BankReferrerId], [ReceiptNumber], [Bank] 
from '+@table_name+' 
where '+@cluster_index_key+' between '+''''+cast(@cluster_index_key_from as varchar(100))+''''+' and '+''''+cast(@cluster_index_key_to as varchar(100))+''''+'
and '+@stop_date_column+' < '+''''+convert(varchar(50),@till_date,121)+''''+'

set @output_rowcount = @@ROWCOUNT
'
--print(@sql_insert)

exec sp_executesql
@sql_insert, 
N'@output_rowcount bigint output', 
@insert_validation_rowcount output

update [master].[dbo].[DonationTransactions_summary]
set inserted = 1
where id = @summary_id

set @sql_validation_insert = N'Select @output_validation = count(*) from '+@arch_table_name+' 
where '+@cluster_index_key+' between '+''''+cast(@cluster_index_key_from as varchar(100))+''''+' and '+''''+cast(@cluster_index_key_to as varchar(100))+''''
--print @sql_validation_insert

exec sp_executesql
@sql_validation_insert, 
N'@output_validation bigint output', 
@insert_validation output

--select  @insert_validation, @insert_validation_rowcount

if  (select inserted from [master].[dbo].[DonationTransactions_summary] where id = @summary_id) = 1 
and (@insert_validation >= @insert_validation_rowcount)
begin
begin try
set @sql_delete = 'delete from '+@table_name+' 
where '+@cluster_index_key+' between '+''''+cast(@cluster_index_key_from as varchar(100))+''''+' and '+''''+cast(@cluster_index_key_to as varchar(100))+''''+'
and '+@stop_date_column+' < '+''''+convert(varchar(50),@till_date,121)+''''

--print (@sql_delete)
exec(@sql_delete)

update [master].[dbo].[DonationTransactions_summary]
set deleted = 1
where id = @summary_id

end try
begin catch
RAISERROR('something went wrong',1,40) WITH NOWAIT; 
end catch
end

waitfor delay '00:00:05'

fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
end
close delete_cursor 
deallocate delete_cursor 

end;
GO


USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_big_table_bulk_Archive_Int]    Script Date: 3/6/2024 4:10:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_big_table_bulk_Archive_Int](
@table_name			nvarchar(500) = '[Ehsan].[dbo].[Donation]', 
@arch_table_name	nvarchar(500) = '[Ehsan].[dbo].[Donation_Archive]', 
@cluster_index_key	nvarchar(300) = '[id]',
@stop_date_column	nvarchar(300) = '[CreationTime]'
)
as
begin

declare 
@summary_id						bigint,
@cluster_index_key_from 		bigint, 
@cluster_index_key_to			bigint,
@sql_delete						nvarchar(max),
@sql_insert						nvarchar(max),
@insert_validation				bigint,
@insert_validation_rowcount 	bigint,
@sql_validation_insert			nvarchar(max)

set nocount on
declare delete_cursor cursor fast_forward
for
select --top 1
id, 
[from_unique_column],
[to_unique_column]
from [master].[dbo].[Donation_summary]
--where id = 4
where unique_id = 1
and inserted = 0
and deleted = 0
order by id 

open delete_cursor 
fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
while @@FETCH_STATUS = 0
begin

set @sql_insert = 'set identity_insert '+@arch_table_name+' on
insert into '+@arch_table_name+' 
([Id], [CreationTime], [CreatorId], [LastModificationTime], [LastModifierId], [DonationAmount], [InitiativeType], [Title], [CaseId], [DonationTransactionId], [ContributionType], [ShowHideAmount], [ShowHideProjectName], [GifteeMobile], [GifteeName], [SenderName])
select 
 [Id], [CreationTime], [CreatorId], [LastModificationTime], [LastModifierId], [DonationAmount], [InitiativeType], [Title], [CaseId], [DonationTransactionId], [ContributionType], [ShowHideAmount], [ShowHideProjectName], [GifteeMobile], [GifteeName], [SenderName]
from '+@table_name+' where '+@cluster_index_key+' between '+cast(@cluster_index_key_from as varchar(100))+' and '+cast(@cluster_index_key_to as varchar(100))+'

set @output_rowcount = @@ROWCOUNT
set identity_insert '+@arch_table_name+' off
'
--print(@sql_insert)
exec sp_executesql
@sql_insert, 
N'@output_rowcount bigint output', 
@insert_validation_rowcount output

--set @insert_validation_rowcount = 1000--@@ROWCOUNT
--select @insert_validation_rowcount 

update [master].[dbo].[Donation_summary]
set inserted = 1
where id = @summary_id

set @sql_validation_insert = N'Select @output_validation = count(*) from '+@arch_table_name+' 
where '+@cluster_index_key+' between '+cast(@cluster_index_key_from as varchar(100))+' and '+cast(@cluster_index_key_to as varchar(100))
--print @sql_validation_insert

exec sp_executesql
@sql_validation_insert, 
N'@output_validation bigint output', 
@insert_validation output

--select  @insert_validation, @insert_validation_rowcount

if  (select inserted from [master].[dbo].[Donation_summary] where id = @summary_id) = 1 
and (@insert_validation = @insert_validation_rowcount)

begin
begin try
set @sql_delete = 'delete from '+@table_name+' where '+@cluster_index_key+' between '+cast(@cluster_index_key_from as varchar(100))+' and '+cast(@cluster_index_key_to as varchar(100))
--print @sql_delete
exec(@sql_delete)

update [master].[dbo].[Donation_summary]
set deleted = 1
where id = @summary_id

end try
begin catch
RAISERROR('something went wrong',1,40) WITH NOWAIT; 
end catch
end

waitfor delay '00:00:03'

fetch next from delete_cursor into @summary_id, @cluster_index_key_from, @cluster_index_key_to
end
close delete_cursor 
deallocate delete_cursor 

end;