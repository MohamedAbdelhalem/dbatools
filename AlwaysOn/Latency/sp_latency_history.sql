USE [master]
GO
CREATE Procedure [dbo].[sp_latency_history] (
@filter					float = 0,
@date					varchar(200) = '2023-05-14 18:25:00 and 2023-05-15 00:00:00',
@order_by				nvarchar(20) = 'date', --date, Latency
@order_by_node			int = 2, --0 = all or 1,2,3,4
@database				nvarchar(255) = 'VRPCrmIntegration',
@desc					bit = 0,
@Only_job				int = 0)
as
begin
declare
@replicas_server_name	varchar(max),
@replicas_ss			varchar(max),
@date_time				varchar(200),
@delay_day				int

if @date = 'default'
begin
set @delay_day = 0
end
else
if @date not like '%and%'
begin
set @delay_day = @date
set @date = 'convert(datetime,convert(varchar(10),getdate()-'+cast(abs(cast(@delay_day as int)) as varchar(10))+',120),120) and dateadd(ms,-2,dateadd(day,1,convert(varchar(10),getdate()-'+cast(abs(cast(@delay_day as int)) as varchar(10))+',120)))'
end

select @replicas_server_name = isnull(@replicas_server_name+',','') + 
case replica_id_rank 
when 1 then 'Primary_node_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Primary_node_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 2 then 'Secondary_node1_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Secondary_node1_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 3 then 'Secondary_node2_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Secondary_node2_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 4 then 'Secondary_node3_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Secondary_node3_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
end
from (
select DENSE_RANK() over(order by ars.role, ar.replica_server_name) replica_id_rank, dbrs.database_id, ar.replica_server_name, ars.role_desc, dbrs.last_commit_time
from  master.sys.dm_hadr_database_replica_states dbrs inner join sys.dm_hadr_availability_replica_states ars
on dbrs.replica_id = ars.replica_id
inner join sys.availability_replicas ar
on dbrs.replica_id = ar.replica_id
where database_id = (select top 1 database_id from sys.databases where database_id > 4))a
order by replica_id_rank

declare @sql nvarchar(max) = '
select id, database_name, '+'
'+@replicas_server_name+',
insert_date, case when 
master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',2)%10 = 0 and master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',3) = ''00'' then 1 else 0 end job_dataLost_should_catch
from msdb.dbo.Latency_log_AG_v
where database_id '+ case when @database is null then '> 0 ' else ' = db_id('+''''+@database+''''+')' end +'
'+
case when @date is null then '' else 'and insert_Date between '+case when dbo.vertical_array(@date,' and ',1) not like '%getdate%' then ''''+dbo.vertical_array(@date,' and ',1)+'''' else dbo.vertical_array(@date,' and ',1) end+
case when dbo.vertical_array(@date,' and ',2) not like '%getdate%' then ' and '+''''+dbo.vertical_array(dbo.vertical_array(@date,' and ',2),' ',2)+' '+dbo.vertical_array(dbo.vertical_array(@date,' and ',2),' ',3)+'''' else dbo.vertical_array(@date,' and ',2) end end+'
'+case @filter
when 0 then '' 
when 1 then ' and Primary_node_Latency_ms + isnull(Secondary_node1_Latency_ms,0) + isnull(Secondary_node2_Latency_ms,0) + isnull(Secondary_node3_Latency_ms,0) > 0' 
else		' and '+case 
					when @order_by_node = 1 then 'Primary_node_Latency_ms' 
					when @order_by_node = 2 then 'Secondary_node1_Latency_ms' 
					when @order_by_node = 3 then 'Secondary_node2_Latency_ms' 
					when @order_by_node = 4 then 'Secondary_node3_Latency_ms' 
					end +' >= '+cast((@filter * 1000) as varchar(10)) end+'
'+case @Only_job when 0 then '' 
when 1 then 'and case when master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',2)%10 = 0 and master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',3) = ''00'' then 1 else 0 end = 1' 
when 2 then 'and case when master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',2)%10 = 0 and master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',3) = ''00'' then 1 else 0 end = 1 and '+case 
					when @order_by_node = 1 then 'Primary_node_Latency_ms' 
					when @order_by_node = 2 then 'Secondary_node1_Latency_ms' 
					when @order_by_node = 3 then 'Secondary_node2_Latency_ms' 
					when @order_by_node = 4 then 'Secondary_node3_Latency_ms' 
					end +' >= '+cast((@filter * 1000) as varchar(10))
end+'
order by '+case @order_by
when 'date' then 'insert_date' 
when 'latency' then case 
when @order_by_node = 0 then 'Primary_node_Latency_ms + isnull(Secondary_node1_Latency_ms,0) + isnull(Secondary_node2_Latency_ms,0) + isnull(Secondary_node3_Latency_ms,0)'
when @order_by_node = 1 then 'Primary_node_Latency_ms'
when @order_by_node = 2 then 'isnull(Secondary_node1_Latency_ms,0)'
when @order_by_node = 3 then 'isnull(Secondary_node2_Latency_ms,0)'
when @order_by_node = 4 then 'isnull(Secondary_node3_Latency_ms,0)'
end end +' '+
case @desc when 1 then 'desc' else 'asc' end

print(@sql)
exec sp_executesql @sql

end
