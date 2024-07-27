select db.name, edition, service_objective, 'ALTER DATABASE ['+db.name+'] MODIFY (EDITION='+''''+edition+''''+', SERVICE_OBJECTIVE='+''''+service_objective+''''+')' script 
from sys.database_service_objectives dbso inner join sys.databases db
on db.database_id = dbso.database_id
go
ALTER DATABASE [AdventureWorksDW2012] MODIFY (EDITION='GeneralPurpose', SERVICE_OBJECTIVE='GP_S_Gen5_1')
go
ALTER DATABASE [DP300] MODIFY (maxsize = 2GB)

