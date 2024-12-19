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

In this example, the stored procedure `usp_2` is created without the `NATIVE_COMPILATION` and `SCHEMABINDING` options. It will be interpreted and can still access the memory-optimized table `T2`[1](https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/creating-a-memory-optimized-table-and-a-natively-compiled-stored-procedure?view=sql-server-ver16)[2](https://www.sqlservercentral.com/articles/natively-compiled-stored-procedures-what-they-are-all-about).


### You can create a procedure that contains memory-optimized tables with both `SCHEMABINDING` and `NATIVE_COMPILATION` options in SQL Server. 

When you create a natively compiled stored procedure, you must use the `NATIVE_COMPILATION` option to indicate that the procedure is natively compiled. Additionally, the `SCHEMABINDING` option is required for natively compiled stored procedures. This means that the tables referenced by the procedure cannot be dropped unless the procedure itself is dropped first. The tables referenced in the procedure must include their schema name, and wildcards (*) are not allowed in queries[1](https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/creating-natively-compiled-stored-procedures?view=sql-server-ver16)[2](https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/native-compilation-of-tables-and-stored-procedures?view=sql-server-ver16).

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

In this example, the `NATIVE_COMPILATION` option indicates that the stored procedure is natively compiled, and the `SCHEMABINDING` option ensures that the procedure is bound to the schema of the objects it references[1](https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/creating-natively-compiled-stored-procedures?view=sql-server-ver16)[2](https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/native-compilation-of-tables-and-stored-procedures?view=sql-server-ver16).


