<p>Some tradeoffs for using <b>Snapshot Isolation Level:</b></p>
<p>1- update after select when session 1 did not commit yet:</p>

```SQL
--Session 1                                             Session 2
--------------------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRANSACTION
UPDATE T1
SET COL1 = 5000
WHERE COL2 = 10;
--Commands completed successfully.
--------------------------------------------------------------------------------------------------------
                                                        SET TRANSACTION ISOLATION LEVEL SNAPSHOT
                                                        BEGIN TRANSACTION
                                                        SELECT COUNT(*)
                                                        FROM T1;
                                                        --Commands completed successfully.
--------------------------------------------------------------------------------------------------------
COMMIT;
--Commands completed successfully.
--------------------------------------------------------------------------------------------------------
                                                        SELECT COL3, COL4, COL5, COL6, COL7
                                                        FROM T1
                                                        WHERE COL2 = 10;
                                                        --Commands completed successfully.      
--------------------------------------------------------------------------------------------------------
                                                        UPDATE T1
                                                        SET COL10 = '2000-01-01 01:10:20'
                                                        WHERE COL2 = 10;
                                                        --Error
```
**In session 2 after you execute the UPDATE statement it will show you the below error message:**

<p><code style="color : red">Msg 3960, Level 16, State 5, Line 5</code></p>
<p><code style="color :red">Snapshot isolation transaction aborted due to update conflict.</code></p>
<p><code style="color : red">You cannot use snapshot isolation to access table 'dbo.T1' directly or indirectly in database 'MYDB' to update, delete, or insert the</code></p>
<p><code style="color : red">row that has been modified or deleted by another transaction. Retry the transaction or change the isolation level for the</code></p>
<p><code style="color : red">update/delete statement.</code></p>

<p>2- update after select when session 1 did not commit yet:</p>

```SQL
--Session 1                                             Session 2
--------------------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRANSACTION
SELECT * FROM T1;
--Commands completed successfully.
--------------------------------------------------------------------------------------------------------
                                                        ALTER INDEX ALL ON T1 REBUILD WITH (ONLINE = ON);
                                                        --Commands completed successfully.
--------------------------------------------------------------------------------------------------------
SELECT * FROM T1;
--LCK_M_SCH_S                     
```
**In session 1 after you execute the SELECT statement it will be blocked LCK_M_SCH_S if session 2 using Read Committed Snapshot Isolation RCSI:**

```SQL
--Session 1                                             Session 2
--------------------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRANSACTION
SELECT * FROM T1;
--Commands completed successfully.
--------------------------------------------------------------------------------------------------------
                                                        SET TRANSACTION ISOLATION LEVEL SNAPSHOT
                                                        ALTER INDEX ALL ON T1 REBUILD WITH (ONLINE = ON);
                                                        --Commands completed successfully.
--------------------------------------------------------------------------------------------------------
SELECT * FROM T1;
--Error                   
```

**In session 1 after you execute the SELECT statement it will show you the below error message:**

<p><code style="color : red">Msg 3961, Level 16, State 1, Line 3</code></p>
<p><code style="color : red">Snapshot isolation transaction failed in database 'MYDB' because the object accessed by the statement has been modified by</code></p> 
<p><code style="color : red">a DDL statement in another concurrent transaction since the start of this transaction.  It is disallowed because the metadata is not versioned.</code></p> 
<p><code style="color : red">A concurrent update to metadata can lead to inconsistency if mixed with snapshot isolation.</code></p>

