use [AdventureWorks2019]
go
select *, FIRST_VALUE(LastName) over(partition by department order by department)
from (
select Department, LastName, row_number() over(partition by department order by department) id
from HumanResources.vEmployeeDepartmentHistory AS edh 
WHERE Department IN (N'Information Services',N'Document Control'))a 
ORDER BY Department 

select *, master.dbo.gBulk(id, 2)
from (
select *, LAST_VALUE(ID) over(partition by department order by department) count_id
from (
select Department, LastName, row_number() over(partition by department order by department) id
from HumanResources.vEmployeeDepartmentHistory AS edh 
WHERE Department IN (N'Information Services',N'Document Control'))a)b
ORDER BY Department 
