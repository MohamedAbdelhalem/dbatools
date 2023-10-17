USE [master]
GO

/****** Object:  Table [dbo].[FBNK_FUNDS_TRANSFER#HIS_summary4]    Script Date: 8/30/2022 3:46:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_summary5](
	[id] [bigint] NULL,
	[unique_id] [bigint] NULL,
	[from_id] [bigint] NULL,
	[to_id] [bigint] NULL,
	[from_unique_column] [varchar](500) NULL,
	[to_unique_column] [varchar](500) NULL
) ON [PRIMARY]
GO


select master.dbo.format(count(*) * 2000, -1), ceiling((14730218.0 / 2000.0) / (1000000 / 2000)),  
 (14730218.0 / 2000.0) / (1000000 / 2000) * (cast(count(*) * 2000 as float)) / 14730218.0 * 100.0 /100.0      [current],
((14730218.0 / 2000.0) / (1000000 / 2000) * (cast(count(*) * 2000 as float)) / 14730218.0 * 100.0 /100.0) + 1 [continue]
from master.[dbo].[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_summary5]
where from_id != to_id

select *
from master.[dbo].[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_summary5]
where from_id != to_id

select master.dbo.duration('s',((5.0 * 60.0)/ 50.0) * 7366.0)
