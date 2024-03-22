declare @table table (recid int identity(1,1), xmlrecord xml)
insert into @table (xmlrecord) values (
'<Types xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey">
  <request>
    <Rollcount>34</Rollcount>
    <general>5</general>
    <land>21</land>
  </request>
</Types>'),
(
'<Types xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey">
  <request>
    <Rollcount>125</Rollcount>
    <general>321</general>
    <land>1000</land>
  </request>
</Types>'),
(
'<Types xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey">
  <request>
    <Rollcount>44</Rollcount>
    <general>60905</general>
    <land>321</land>
  </request>
</Types>'),
(
'<Types xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey">
  <request>
    <Rollcount>3664</Rollcount>
    <general>876</general>
    <land>421</land>
  </request>
</Types>')

--select xmlrecord.value('(/Types/request/land)[1]','nvarchar(max)'), * from @table
--select xmlrecord.query('data(/Types/request/Rollcount)'), * from @table

;WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' as m)
select 
recid, 
xmlrecord.value('(/m:Types/m:request/m:Rollcount)[1]', 'NVARCHAR(200)') Rollcount,
xmlrecord.value('(/m:Types/m:request/m:general)[1]', 'NVARCHAR(200)') general,
xmlrecord.value('(/m:Types/m:request/m:land)[1]', 'NVARCHAR(200)') land
from @table
order by recid

go

;with XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' as xm)
select sum(Demographics.value('(/xm:IndividualSurvey/xm:TotalPurchaseYTD)[1]', 'float')) over() TotalPurchaseYTD,
		Demographics, *
from Person.Person	
order by BusinessEntityID

go
declare @table table (id int identity(1,1), record xml)
insert into @table (record) values ('<Ghiras>
<Id>4F3A2E4F3A2E4F3A2E4F3A2E4F3A2E4F3A2E4F3A2E4F3A2E</Id>
<Amount>1.00</Amount>
</Ghiras>')

select max(len(record.value('data(/Ghiras/Id)[1]','nvarchar(max)'))) from @table
