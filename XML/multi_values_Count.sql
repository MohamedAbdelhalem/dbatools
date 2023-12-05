CREATE FUNCTION [dbo].[multi_values_Count](@col varchar(10), @recid varchar(255), @xmlrecord XML)
RETURNS int 
BEGIN
declare @count int 

select @count = count(*)
from (
select 
row_number() over(order by @recid) row_num,  
T.C.value('.', 'varchar(255)') c1
FROM @XMLRECORD.nodes('(/row/*[local-name(.)=sql:variable("@col")])') as T(C))a
--where row_num > 1

return @count
end
