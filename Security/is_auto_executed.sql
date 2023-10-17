use master
go
select name 
from sys.procedures
where is_auto_executed = 1
