Some treadoffs for using SNAPSHOT ISOLATION LEVEL
1- update after select when session 1 did not commit yet

Session 1                                                                                    Session 2
```SQL
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRANSACTION
UPDATE T1
SET COL1 = 5000
WHERE COL2 = 10;

-------------------------------------------------------------------------------------------------------------------------------------------
                                                                                        SET TRANSACTION ISOLATION LEVEL SNAPSHOT
                                                                                        BEGIN TRANSACTION
                                                                                        SELECT COUNT(*)
                                                                                        FROM T1;
