select 'ALTER DATABASE ['+name+'] SET AUTO_CLOSE OFF WITH NO_WAIT' 
from sys.databases
where is_auto_close_on = 1
