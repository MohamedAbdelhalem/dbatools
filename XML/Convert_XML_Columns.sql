select replace(case when charindex('/>',value) = 0 then master.dbo.virtical_array( value,'>',2) collate Arabic_100_CI_AS else master.dbo.virtical_array(substring(value, charindex('/><',value)+3,len(value)),'>',1) collate Arabic_100_CI_AS end ,'<','') XML_COLUMN_NAME, 
case when charindex('/>',value) = 0 then master.dbo.virtical_array( value,'>',3) collate Arabic_100_CI_AS else master.dbo.virtical_array(substring(value, charindex('/><',value)+3,len(value)),'>',3) collate Arabic_100_CI_AS end XML_COLUMN_RECORD--, value
from FBNK_FUNDS_TRANSFER#HIS_5000 t cross apply master.dbo.Separator(NVARCHAR_MAX ,'</') s
where RECID = 'FT22208790903550;1'
