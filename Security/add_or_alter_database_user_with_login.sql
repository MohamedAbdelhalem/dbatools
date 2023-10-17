exec sp_msforeachdb 'USE [?]
if exists (select * from sys.sysusers where name = ''Tripwire'')
begin
ALTER USER [Tripwire] with LOGIN = [Tripwire]
ALTER ROLE [db_datareader] ADD MEMBER [Tripwire]
end
else
begin
CREATE USER [Tripwire] for LOGIN [Tripwire]
ALTER ROLE [db_datareader] ADD MEMBER [Tripwire]
end'



