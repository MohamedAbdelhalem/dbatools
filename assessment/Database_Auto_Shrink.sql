select 'ALTER DATABASE ['+name+'] SET AUTO_SHRINK OFF WITH NO_WAIT' 
from sys.databases
where is_auto_shrink_on = 1
