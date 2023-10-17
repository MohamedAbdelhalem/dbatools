/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
xmlrecord.value('(/row/c1/text())[1]', 'varchar(255)')
  FROM [T24_support].[dbo].[FENJ_RE_SELECTED_ENTRIES]


SELECT RECID 
FROM "V_FENJ_STMT_ENTRY" 
WHERE RECID IN (SELECT xmlrecord.value('(/row/c1/text())[1]', 'varchar(255)') FROM [T24_support].[dbo].[FENJ_RE_SELECTED_ENTRIES])
ORDER BY "TRANS_REFERENCE" DESC

