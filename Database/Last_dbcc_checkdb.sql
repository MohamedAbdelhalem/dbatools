use master
go
declare 
@sql		  nvarchar(max), 
@db_name	nvarchar(500)

if object_id('tempdb..database_details') is not null
begin
drop table tempdb..database_details 
end

create table tempdb..database_details (
compatibility_level	int, 
database_id			    int, 
database_name		    varchar(500), 
last_dbcc_checkdb	  datetime, 
Last_Log_Backup		  datetime)

declare SQL_CUR	 cursor fast_forward
for
select name 
from sys.databases
where database_id > 4
order by name

open SQL_CUR
fetch next from SQL_CUR into @db_name
while @@FETCH_STATUS = 0
begin
set @sql = 'use ['+@db_name+']
declare @checkdb table (
ParentObject	varchar(1000), 
Object			  varchar(1000), 
Field			    varchar(1000), 
VALUE			    varchar(1000))

insert into @checkdb 
exec(''dbcc page (0,1,9,3) with tableresults'')

insert into tempdb..database_details 
select *
from (
select 
VALUE, case Field 
when ''dbi_LastLogBackupTime'' then ''LastLogBackup''
when ''dbi_dbname''            then ''database_name''
when ''dbi_dbid''              then ''database_id''
when ''dbi_cmptlevel''         then ''compatibility_level''
when ''dbi_dbccLastKnownGood'' then ''last_dbcc_checkdb''
end Field
from @checkdb
where Field in (
''dbi_LastLogBackupTime'',
''dbi_dbname'',
''dbi_dbid'',
''dbi_cmptlevel'',
''dbi_dbccLastKnownGood''))a
pivot
(max(VALUE) for Field in ([compatibility_level],[database_id],[database_name],[last_dbcc_checkdb],[LastLogBackup]))p'

--print(@sql)
exec(@sql)

fetch next from SQL_CUR into @db_name
end
close SQL_CUR
deallocate SQL_CUR

select * 
from tempdb..database_details
order by last_dbcc_checkdb desc
