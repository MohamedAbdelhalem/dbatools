USE [master]
GO
CREATE TABLE [dbo].[restore_notification](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[database_name] [varchar](500) NULL,
	[status] [int] NULL,
	[start_time] [datetime] NULL,
	[finish_time] [datetime] NULL,
	[total_files] [int] NULL,
	[current_file] [int] NULL,
	[last_file_name] [varchar](1000) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[restore_loction_groups](
	[directorys_map] [varchar](2000) NULL
) ON [PRIMARY]
GO

declare @physical_name varchar(2000) = ''
select 
@physical_name = cast(data_space_id as varchar)+'-'+physical_name+';' + @physical_name
from (
select distinct data_space_id, reverse(substring(reverse(physical_name), charindex('\',reverse(physical_name)), len(physical_name))) physical_name
from sys.master_files
where db_name(database_id) = 'T24SDC22')a
order by data_space_id desc, physical_name 

select @physical_name 

insert into [dbo].[restore_loction_groups] values (substring(@physical_name,1,len(@physical_name)-1))

select * from [dbo].[restore_loction_groups] 
