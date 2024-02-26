USE [master]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_executionPlan_Pvalues]    Script Date: 9/20/2023 3:17:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[fn_executionPlan_params]
(@plan XML)
returns @table table (id int identity(1,1), bind_variables varchar(1000), parameter_values nvarchar(1000), ParameterRuntimeValue nvarchar(1000))
as
begin

;WITH xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
insert into @table
SELECT DISTINCT
[bind_variables]			= x.value('(@Column)[1]',   'varchar(1000)'),
[parameters]				= x.value('(@ParameterCompiledValue)[1]', 'nvarchar(1000)'),
[ParameterRuntimeValue]		= x.value('(@ParameterRuntimeValue)[1]', 'nvarchar(1000)')
FROM   @plan.nodes('//ColumnReference') x1(x)
where x.value('(@Column)[1]','varchar(1000)') like '%@%'
and x.value(N'(@ParameterCompiledValue)[1]',N'varchar(1000)') is not null

return
end
