--If you want to have a uniqueidentifier as a cluster index key for a table you usually use NEWID() function to generate a new id as a default value
--However, using this method will lead to frequent page splits, ultimately causing significant overhead. 

CREATE TABLE seq_test_newid (id INT IDENTITY(1,1), rid UNIQUEIDENTIFIER DEFAULT NEWID(), name VARCHAR(100))
GO
INSERT INTO seq_test_newid (name) VALUES ('Mohamed')
GO 1000

SELECT * 
FROM seq_test_newid 
ORDER BY rid

--meanwhile, when you use NEWSEQUENTIALID() instead of NEWID() function the behavior will change on the other hand.
--let's see the changes here.

CREATE TABLE seq_test_newsequentialid (id INT IDENTITY(1,1), rid UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID(), name VARCHAR(100))
GO
INSERT INTO seq_test_newsequentialid (name) VALUES ('Mohamed')
GO 1000

SELECT * 
FROM seq_test_newsequentialid 
ORDER BY rid
