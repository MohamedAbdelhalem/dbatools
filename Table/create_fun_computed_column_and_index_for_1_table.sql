--V_LDFBNK_LD_L001
--FIN_MAT_DATE
--CATEGORY
--SAR_AMOUNT
--FIN_MAT_DATE

select s.*
from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s
where object_id = object_id('V_LDFBNK_LD_L001')
and (s.value like '%"FIN_MAT_DATE"%'
or s.value like '%"CATEGORY"%'
or s.value like '%"SAR_AMOUNT"%'
)
order by s.id
go
CREATE FUNCTION [dbo].LDFBNK_LD_L001_c167_m82(@xmlrecord XML)
RETURNS nvarchar(16)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.query('/row/c167[@m="82"]').value('/c167[1]', 'nvarchar(16)');
END
go

alter table LDFBNK_LD_L001 
add 
[SAR_AMOUNT] as (dbo.LDFBNK_LD_L001_c167_m82(XMLRECORD))
go
select top 100 * from LDFBNK_LD_L001
go
exec sp_table_size '','LDFBNK_LD_L001'
go
create nonclustered index idx_LDFBNK_LD_L001_c167_m82 on LDFBNK_LD_L001 ([SAR_AMOUNT]) with (online=on)
