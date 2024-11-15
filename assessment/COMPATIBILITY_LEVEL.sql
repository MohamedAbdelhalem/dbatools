select name, 'ALTER DATABASE ['+name+']  SET COMPATIBILITY_LEVEL = '+cast(cast(serverproperty('ProductMajorVersion') as int) *10 as varchar(10))
from sys.databases
where compatibility_level != cast(serverproperty('ProductMajorVersion') as int) *10 
