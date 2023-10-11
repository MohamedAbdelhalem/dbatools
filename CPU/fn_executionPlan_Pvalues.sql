create function fn_executionPlan_Pvalues
(@session_id int)
returns @table table (id int identity(1,1), bind_variables varchar(255), parameter_values nvarchar(255))
as
begin
declare @plan XML

SELECT @plan = qplan.query_plan 
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) qplan 
cross apply sys.dm_exec_sql_text(r.plan_handle) qtext 
where r.session_id = @session_id

;WITH xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
insert into @table
SELECT DISTINCT
[bind_variables]	= x.value('(@Column)[1]',   'varchar(128)'),
[parameters]		= x.value('(@ParameterCompiledValue)[1]',   'varchar(128)')
FROM   @plan.nodes('//ColumnReference') x1(x)
where x.value('(@Column)[1]','varchar(128)') like '%@%'
and x.value(N'(@ParameterCompiledValue)[1]',N'varchar(128)') is not null

return
end
