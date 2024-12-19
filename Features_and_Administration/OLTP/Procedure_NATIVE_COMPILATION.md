### You can create a stored procedure that accesses memory-optimized tables without using the `NATIVE_COMPILATION` and `SCHEMABINDING` options. In this case, the procedure will be interpreted rather than natively compiled. Here is an example:

```sql
CREATE TABLE [dbo].[T2] (
    [c1] [int] NOT NULL,
    [c2] [datetime] NOT NULL,
    [c3] [nvarchar(5)] NOT NULL,
    CONSTRAINT [PK_T1] PRIMARY KEY NONCLUSTERED ([c1])
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE PROCEDURE [dbo].[usp_2] (@c1 int, @c3 nvarchar(5))
AS
BEGIN
    DECLARE @c2 datetime = GETDATE();
    INSERT INTO [dbo].[T2] (c1, c2, c3) VALUES (@c1, @c2, @c3);
END;
GO
```

In this example, the stored procedure `usp_2` is created without the `NATIVE_COMPILATION` and `SCHEMABINDING` options. It will be interpreted and can still access the memory-optimized table `T2`


### You can create a procedure that contains memory-optimized tables with both `SCHEMABINDING` and `NATIVE_COMPILATION` options in SQL Server. 

When you create a natively compiled stored procedure, you must use the `NATIVE_COMPILATION` option to indicate that the procedure is natively compiled. Additionally, the `SCHEMABINDING` option is required for natively compiled stored procedures. This means that the tables referenced by the procedure cannot be dropped unless the procedure itself is dropped first. The tables referenced in the procedure must include their schema name, and wildcards (*) are not allowed in queries.

Here is an example of how you can create a natively compiled stored procedure with `SCHEMABINDING`:

```sql
CREATE TABLE [dbo].[T2] (
    [c1] [int] NOT NULL,
    [c2] [datetime] NOT NULL,
    [c3] [nvarchar(5)] NOT NULL,
    CONSTRAINT [PK_T1] PRIMARY KEY NONCLUSTERED ([c1])
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE PROCEDURE [dbo].[usp_2] (@c1 int, @c3 nvarchar(5))
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC
    WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
    DECLARE @c2 datetime = GETDATE();
    INSERT INTO [dbo].[T2] (c1, c2, c3) VALUES (@c1, @c2, @c3);
END;
GO
```

In this example, the `NATIVE_COMPILATION` option indicates that the stored procedure is natively compiled, and the `SCHEMABINDING` option ensures that the procedure is bound to the schema of the objects it references.


### You can create a stored procedure with the `NATIVE_COMPILATION` option even if it accesses both memory-optimized tables and traditional row-based tables. However, there are some important considerations and limitations to keep in mind:

1. **Memory-Optimized Tables**: The procedure can access memory-optimized tables, but it must adhere to the constraints and requirements of natively compiled stored procedures. This includes using the `SCHEMABINDING` option and ensuring that all referenced objects are schema-bound.

2. **Row-Based Tables**: While you can reference traditional row-based tables in a natively compiled stored procedure, there are limitations on the types of operations you can perform. For example, you cannot use certain Transact-SQL features that are not supported in natively compiled stored procedures.

Here is an example of how you can create a natively compiled stored procedure that accesses both memory-optimized and row-based tables:

```sql
CREATE TABLE [dbo].[MemoryOptimizedTable] (
    [ID] [int] NOT NULL PRIMARY KEY NONCLUSTERED,
    [Value] *An external link was removed to protect your privacy.* NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE TABLE [dbo].[RowBasedTable] (
    [ID] [int] NOT NULL PRIMARY KEY,
    [Description] *An external link was removed to protect your privacy.* NOT NULL
);
GO

CREATE PROCEDURE [dbo].[usp_MixedTables]
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC
    WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
    DECLARE @ID int = 1;
    DECLARE @Value nvarchar(50) = 'Sample Value';
    DECLARE @Description nvarchar(100);

    -- Insert into memory-optimized table
    INSERT INTO [dbo].[MemoryOptimizedTable] (ID, Value) VALUES (@ID, @Value);

    -- Select from row-based table
    SELECT @Description = Description FROM [dbo].[RowBasedTable] WHERE ID = @ID;

    -- Insert into row-based table
    INSERT INTO [dbo].[RowBasedTable] (ID, Description) VALUES (@ID, @Description);
END;
GO
```

In this example, the stored procedure `usp_MixedTables` is natively compiled and accesses both a memory-optimized table (`MemoryOptimizedTable`) and a traditional row-based table (`RowBasedTable`). The procedure uses the `NATIVE_COMPILATION` and `SCHEMABINDING` options and performs operations on both types of tables.
