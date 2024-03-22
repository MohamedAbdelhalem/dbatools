use AdventureWorks2022
go
/*
<AdditionalContactInfo 
	xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo" 
	xmlns:crm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord" 
	xmlns:act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes">
  
	<crm:ContactRecord date="2002-01-01Z">Sales contacted this customer for the first time at
		<act:telephoneNumber>
			<act:number>432-4444
			</act:number>
		</act:telephoneNumber>We talked about the Road bike price drop and the new spring models. Customer provided us new mobile number
		<act:mobile>
			<act:number>432-555-7809
			</act:number>
		</act:mobile>
	</crm:ContactRecord>
</AdditionalContactInfo>
*/
;with XMLNAMESPACES(
'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo' as c,
'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord' as crm,
'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes' as act
)
select 
BusinessEntityID, AdditionalContactInfo,
AdditionalContactInfo.value('(/*/crm:ContactRecord/@date)[1]', 'NVARCHAR(200)') as ContactRecord_date,
AdditionalContactInfo.value('(/*/act:telephoneNumber/act:number)[1]', 'NVARCHAR(200)') as Telephone_Number,
AdditionalContactInfo.query('(/*/crm:ContactRecord)').value('(/crm:ContactRecord)[1]','varchar(max)') as ContactRecord_value,
AdditionalContactInfo.value('(/*/crm:ContactRecord/act:telephoneNumber/act:number)[1]', 'NVARCHAR(200)') as Telephone_Number,
AdditionalContactInfo.value('(/*/crm:ContactRecord/act:mobile/act:number)[1]', 'NVARCHAR(200)') as Mobile_Number
from Person.Person	
where BusinessEntityID = 299
go
/*
<AdditionalContactInfo 
	xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo" 
	xmlns:crm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord" 
	xmlns:act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes">
  <act:telephoneNumber>
    <act:number>425-555-1112</act:number>
    <act:SpecialInstructions>Call only after 5:00 p.m.</act:SpecialInstructions>
  </act:telephoneNumber>Note that the customer has a secondary home address.
  <act:homePostalAddress>
		<act:Street>123 Oak</act:Street>
		<act:City>Seattle</act:City>
		<act:StateProvince>WA</act:StateProvince>
		<act:PostalCode>98001</act:PostalCode>
		<act:CountryRegion>USA</act:CountryRegion>
		<act:SpecialInstructions>If correspondence to the primary address fails, try this one.</act:SpecialInstructions>
  </act:homePostalAddress>Customer provided additional email address.
  <act:eMail>
		<act:eMailAddress>customer1@sample.com</act:eMailAddress>
		<act:SpecialInstructions>For urgent issues, do not send e-mail. Instead use this emergency contact phone
			<act:telephoneNumber>
				<act:number>425-555-1111</act:number>
			</act:telephoneNumber>.
		</act:SpecialInstructions>
	</act:eMail>
	<crm:ContactRecord date="2001-06-02Z">This customer is interested in purchasing high-end bicycles for his family. The customer contacted Michael in sales.</crm:ContactRecord>
</AdditionalContactInfo>
*/
;with XMLNAMESPACES(
'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo' as c,
'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord' as crm,
'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes' as act
)
select 
BusinessEntityID, AdditionalContactInfo,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:telephoneNumber/act:number)[1]', N'NVARCHAR(200)') as Telephone_Number,
AdditionalContactInfo.query(N'(/c:AdditionalContactInfo/act:telephoneNumber/act:SpecialInstructions)').value('(/act:SpecialInstructions)[1]','varchar(max)') as telephoneNumber_SpecialInstructions,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:homePostalAddress/act:Street)[1]', N'NVARCHAR(200)') as homePostalAddress_Street,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:homePostalAddress/act:City)[1]', N'NVARCHAR(200)') as homePostalAddress_City,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:homePostalAddress/act:StateProvince)[1]', N'NVARCHAR(200)') as homePostalAddress_StateProvince,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:homePostalAddress/act:PostalCode)[1]', N'NVARCHAR(200)') as homePostalAddress_PostalCode,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:homePostalAddress/act:CountryRegion)[1]', N'NVARCHAR(200)') as homePostalAddress_CountryRegion,
AdditionalContactInfo.query(N'(/c:AdditionalContactInfo/act:homePostalAddress/act:SpecialInstructions)').value('(/act:SpecialInstructions)[1]','varchar(max)') as homePostalAddress_SpecialInstructions,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:eMail/act:eMailAddress)[1]', N'NVARCHAR(200)') as eMail_eMailAddress,
AdditionalContactInfo.query(N'(/c:AdditionalContactInfo/act:eMail/act:SpecialInstructions)').value('(/act:SpecialInstructions)[1]','varchar(max)') as eMail_SpecialInstructions,
AdditionalContactInfo.value(N'(/c:AdditionalContactInfo/act:eMail/act:SpecialInstructions/act:telephoneNumber/act:number)[1]', N'NVARCHAR(200)') as eMail_number,
AdditionalContactInfo.value('(/*/crm:ContactRecord/@date)[1]', 'NVARCHAR(200)') as ContactRecord_date,
AdditionalContactInfo.query('(/*/crm:ContactRecord)').value('(/crm:ContactRecord)[1]','varchar(max)') as ContactRecord_value
from Person.Person	
where BusinessEntityID = 291

