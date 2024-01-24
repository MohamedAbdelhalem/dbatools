--exec master.dbo.database_size @with_system = 1, @databases ='Data_Hub_T24', @volumes = 'E', @sorted_by='size', @force_shrink_log =1

declare @sql varchar(1000), @db_name varchar(500) = db_name(db_id())
declare @vlf table (id int identity(1,1), 
RecoveryUnitId int, FileId int, FileSize bigint, StartOffset bigint, FSeqNo bigint, Status int, Parity int, CreateLSN varchar(100))
set @sql = 'use ['+@db_name+'] DBCC LOGINFO'
insert into @vlf
exec(@sql)

select FileId,
master.dbo.numbersize(sum((FileSize)/1024.0/1024.0),'M') [available size can be shrink]
from @vlf
where id > (
select max(id) id
from @vlf
where status = 2
group by status)
group by FileId

select id, RecoveryUnitId, FileId, master.dbo.numbersize((FileSize/1024.0/1024.0),'M')  
StartOffset, FSeqNo, Status, Parity, CreateLSN
from @vlf

select FileId,case status 
when 0 then 'inactive' 
when 1 then 'initialized but unused' 
when 2 then 'active' 
end status_desc, master.dbo.numbersize(sum((FileSize)/1024.0/1024.0),'M') [size],
case when CreateLSN = '0' then 0 else 1 end has_LSN, Parity
from @vlf
group by status, FileId,case when CreateLSN = '0' then 0 else 1 end, Parity

select count(*) number_vlf,FileId,
[group 50], 
master.dbo.numbersize(sum((FileSize)/1024.0/1024.0),'M') [size each group],
max([total size])
from (
select master.dbo.gbulk(id, 50) [group 50], FileId,
FileSize,
master.dbo.numbersize((sum(FileSize) over())/1024.0/1024.0,'M') [total size]
from @vlf)a
group by FileId,[group 50]


--USE [Data_Hub_T24]   DBCC SHRINKFILE (N'Data_Hub_T24_DEV_log' , 57)
