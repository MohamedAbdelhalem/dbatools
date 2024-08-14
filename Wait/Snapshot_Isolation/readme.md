<code style="color : green">text</code>
Some tradeoffs for using SNAPSHOT ISOLATION LEVEL
1- update after select when session 1 did not commit yet

<span style="color:blue">some *blue* text</span>.
```SQL
--Session 1                                             Session 2
--------------------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRANSACTION
UPDATE T1
SET COL1 = 5000
WHERE COL2 = 10;
--------------------------------------------------------------------------------------------------------
                                                        SET TRANSACTION ISOLATION LEVEL SNAPSHOT
                                                        BEGIN TRANSACTION
                                                        SELECT COUNT(*)
                                                        FROM T1;
--------------------------------------------------------------------------------------------------------
COMMIT;
--------------------------------------------------------------------------------------------------------
                                                        SELECT COL3, COL4, COL5, COL6, COL7
                                                        FROM T1
                                                        WHERE COL2 = 10;
--------------------------------------------------------------------------------------------------------
                                                        UPDATE T1
                                                        SET COL10 = '2000-01-01 01:10:20'
                                                        WHERE COL2 = 10;

```
**In session 2 after you execute the update statement it will show you the below error message**

<p><code style="color : red">Msg 3960, Level 16, State 5, Line 5</code></p>
<p><code style="color :red">Snapshot isolation transaction aborted due to update conflict.</code></p>
<p><code style="color : red">You cannot use snapshot isolation to access table 'dbo.T1' directly or indirectly in database 'MYDB' to update, delete, or insert the</code></p>
<p><code style="color : red">row that has been modified or deleted by another transaction. Retry the transaction or change the isolation level for the</code></p>
<p><code style="color : red">update/delete statement.</code></p>


