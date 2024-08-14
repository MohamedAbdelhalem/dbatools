Some tradeoffs for using SNAPSHOT ISOLATION LEVEL
1- update after select when session 1 did not commit yet

```SQL
--Session 1                                                          Session 2
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
-------------------------------------------------------------------------------------------------------------------------------------------
COMMIT;
-------------------------------------------------------------------------------------------------------------------------------------------
                                                                     SELECT COL3, COL4, COL5, COL6, COL7
                                                                     FROM T1
                                                                     WHERE COL2 = 10;
-------------------------------------------------------------------------------------------------------------------------------------------
                                                                     UPDATE T1
                                                                     SET COL10 = '2000-01-01 01:10:20'
                                                                     WHERE COL2 = 10;
                                                                     MSG ERROR
