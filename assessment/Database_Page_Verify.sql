select page_verify_option_desc, 'ALTER DATABASE ['+name+'] SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT' 
from sys.databases
where page_verify_option_desc != 'CHECKSUM'
