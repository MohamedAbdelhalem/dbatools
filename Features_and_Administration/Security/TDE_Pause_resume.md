## Before 2019

Before SQL Server 2019, you could use a trace flag to pause the TDE encryption scan. Specifically, **trace flag 5004** was used to suspend the encryption process. Here’s how you could use it:

### Steps to Pause TDE Encryption Using Trace Flag 5004

1. **Enable Trace Flag 5004**:
   - This command suspends the TDE encryption scan.
   ```sql
   DBCC TRACEON(5004, -1);
   GO
   ```

2. **Verify the Encryption State**:
   - Check the encryption state to ensure it has been paused.
   ```sql
   SELECT 
       database_id,
       encryption_state,
       encryption_scan_state,
       encryption_scan_modify_date
   FROM 
       sys.dm_database_encryption_keys;
   GO
   ```

### Steps to Resume TDE Encryption

1. **Disable Trace Flag 5004**:
   - This command resumes the TDE encryption scan.
   ```sql
   DBCC TRACEOFF(5004, -1);
   GO
   ```

2. **Verify the Encryption State Again**:
   - Check the encryption state to ensure it has resumed.
   ```sql
   SELECT 
       database_id,
       encryption_state,
       encryption_scan_state,
       encryption_scan_modify_date
   FROM 
       sys.dm_database_encryption_keys;
   GO
   ```

### Example Scenario
If you have a database named `SalesDB` and you want to pause the TDE encryption scan during peak business hours, you would run:
```sql
DBCC TRACEON(5004, -1);
GO
```
Later, to resume the encryption scan, you would run:
```sql
DBCC TRACEOFF(5004, -1);
GO
```

This approach helps manage the performance impact of TDE encryption on your SQL Server instance.

## Starting in 2019 or earlier

To pause Transparent Data Encryption (TDE) in SQL Server, you can use the `ALTER DATABASE` command with the `SET ENCRYPTION SUSPEND` option. This feature was introduced in SQL Server 2019 and allows you to suspend the encryption scan during heavy workloads or business-critical hours. Here are the steps:

### Steps to Pause TDE Encryption

1. **Connect to the SQL Server Instance**:
   - Open SQL Server Management Studio (SSMS) and connect to your SQL Server instance.

2. **Suspend the TDE Encryption Scan**:
   - Use the following T-SQL command to pause the encryption scan:
     ```sql
     ALTER DATABASE YourDatabaseName
     SET ENCRYPTION SUSPEND;
     GO
     ```

3. **Verify the Encryption Scan State**:
   - You can check the current state of the encryption scan using the `sys.dm_database_encryption_keys` dynamic management view (DMV):
     ```sql
     SELECT 
         database_id,
         encryption_state,
         encryption_scan_state,
         encryption_scan_modify_date
     FROM 
         sys.dm_database_encryption_keys;
     GO
     ```

### Steps to Resume TDE Encryption

1. **Resume the TDE Encryption Scan**:
   - When you are ready to resume the encryption scan, use the following T-SQL command:
     ```sql
     ALTER DATABASE YourDatabaseName
     SET ENCRYPTION RESUME;
     GO
     ```

2. **Verify the Encryption Scan State Again**:
   - Check the state again to ensure the encryption scan has resumed:
     ```sql
     SELECT 
         database_id,
         encryption_state,
         encryption_scan_state,
         encryption_scan_modify_date
     FROM 
         sys.dm_database_encryption_keys;
     GO
     ```

### Example Scenario
If you have a database named `SalesDB` and you want to pause the TDE encryption scan during peak business hours, you would run:
```sql
ALTER DATABASE SalesDB
SET ENCRYPTION SUSPEND;
GO
```
Later, to resume the encryption scan, you would run:
```sql
ALTER DATABASE SalesDB
SET ENCRYPTION RESUME;
GO
```

This approach helps manage the performance impact of TDE encryption on your SQL Server instance.

