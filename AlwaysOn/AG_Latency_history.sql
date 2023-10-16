declare 
@filter					int = 0,
@date					varchar(100) = '2023-05-17 00:00:00 and 2023-05-18 00:00:00',
@order_by				nvarchar(20) = 'date', --date, Latency
@order_by_node			int = 2, --0 = all or 1,2,3,4
@database				nvarchar(255) = NULL,
@desc					bit = 0,
@replicas_server_name	varchar(max),
@replicas_ss			varchar(max)

select @replicas_server_name = isnull(@replicas_server_name+',','') + 
case replica_id_rank 
when 1 then 'Primary_node_Latency as ['+replica_server_name+'], cast(Primary_node_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 2 then 'Secondary_node1_Latency as ['+replica_server_name+'], cast(Secondary_node1_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 3 then 'Secondary_node2_Latency as ['+replica_server_name+'], cast(Secondary_node2_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 4 then 'Secondary_node3_Latency as ['+replica_server_name+'], cast(Secondary_node3_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
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
insert_date
from msdb.dbo.Latency_log_AG_v
where database_id '+ case when @database is null then '> 0 ' else ' = db_id('+''''+@database+''''+')
'+cast(case when @date is null then '' else 'and insert_Date between '+''''+replace(convert(varbinary(max),replace(replace(@date,' a','_a'),'d ','d_')),0x5F,0x27)+'''' end as nvarchar(200))+'
'+case @filter
when 0 then '' 
when 1 then ' and Primary_node_Latency_ms + isnull(Secondary_node1_Latency_ms,0) + isnull(Secondary_node2_Latency_ms,0) + isnull(Secondary_node3_Latency_ms,0) > 0' 
else		' and Primary_node_Latency_ms >= '+cast(@filter as varchar(10))+' or isnull(Secondary_node1_Latency_ms,0) >= '+cast(@filter as varchar(10))+' or isnull(Secondary_node2_Latency_ms,0) >= '+cast(@filter as varchar(10))+' or isnull(Secondary_node3_Latency_ms,0) >= '+cast(@filter as varchar(10)) 
end+'
' end +'order by '+case @order_by
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

--summary table sizing




--exec msdb..sp_table_size '','[dbo].[Latency_log_AG_v]'

--name				table_name					rows_n	fg_type		scheme_filegroup	total_pages	used_pages	unused_pages	data_pages	index_pages	total_pages_n
--Latency_log_AG_v	[dbo].[Latency_log_AG_v]	2,208	FILEGROUP	PRIMARY				392 KB		352 KB		40 KB			344 KB		8 KB		392

