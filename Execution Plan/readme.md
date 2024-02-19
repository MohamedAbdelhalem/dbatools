Read the execution plan from extended events or get the values of the parameters to help you identify the query slowness by testing the query with its values.

# Recompile Stored procedure to eliminate the parameter sniffing issue #

Recompiling a stored procedure can help to eliminate the parameter sniffing issue if you have one. Parameter sniffing occurs when the SQL Server uses the first set of parameters passed to a stored procedure to create an execution plan that is then cached and reused for subsequent calls to the stored procedure. If the first set of parameters is not representative of the typical values passed to the stored procedure, the cached execution plan may not be optimal for most calls to the stored procedure, resulting in poor performance. Recompiling the stored procedure forces the SQL Server to create a new execution plan based on the current set of parameters, which can help to eliminate the parameter sniffing issue. However, recompiling a stored procedure can be an expensive operation, so it should be used judiciously.

