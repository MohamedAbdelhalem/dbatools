CREATE FUNCTION [dbo].[fn_FBNK_BAB_004_c4_MV] (@xmlrecord XML)
RETURNS Varchar(1000)
WITH SCHEMABINDING
BEGIN
declare @multi_value Varchar(1000)
select @multi_value = isnull(@multi_value+'^','')+T.C.value('.', 'varchar(12)')
FROM @XMLRECORD.nodes('(/row/c4)') as T(C)

RETURN @multi_value
END