-The outcome of the script **Get-DiskMaps**

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Get-DiskMaps.gif)


-The outcome of the script **File-Transfer-with-state**

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/File-Transfer-with-state.gif)


#use Copy_mssql.ps1 to copy file with progress (percent, and time), create the table first and you can use this script from dbatools/database/datafile_move/

```SQL

use master
go
If OBJECT_ID('[dbo].[Copy_Progress]') is not NULL
Begin
	Drop Table [dbo].[Copy_Progress]
	Create Table [dbo].[Copy_Progress] ([File_Name] varchar(1000), [Percent_complete] Varchar(25), [Time_to_Complete] Varchar(25))
end
else
Begin
	Create Table [dbo].[Copy_Progress] ([File_Name] varchar(1000), [Percent_complete] Varchar(25), [Time_to_Complete] Varchar(25))
end
```
then use the below select to know the Percent_Complete and Time_to_Complete

```SQL

use master
go
Select * from [dbo].[Copy_Progress]

```
