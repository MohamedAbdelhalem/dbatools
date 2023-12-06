select oo.*,ss.login_name, ss.program_name, ss.status, ss.host_name, r.command --, pr.text
from (
select resource_type, 
db_name(resource_database_id) database_name, 
case 
when resource_type = 'KEY' then OBJECT_NAME(a.object_id,resource_database_id)
when resource_type = 'Object' then OBJECT_NAME(tl.resource_associated_entity_id,resource_database_id)
when resource_type = 'PAGE' then master.dbo.virtical_array(resource_description,':',1)
when resource_type = 'APPLICATION' then 
master.dbo.virtical_array(substring(resource_description,CHARindex('[',resource_description)+1,CHARindex(']',resource_description)-CHARindex('[',resource_description)-1),'*',1) collate Arabic_100_CI_AS
end [object_name / fileid], 
a.object_id,resource_database_id,
case 
when resource_type = 'KEY' then resource_description
when resource_type = 'PAGE' then master.dbo.virtical_array(resource_description,':',2)
when resource_type = 'APPLICATION' then 
master.dbo.virtical_array(substring(resource_description,CHARindex('[',resource_description)+1,CHARindex(']',resource_description)-CHARindex('[',resource_description)-1),'*',2) collate Arabic_100_CI_AS
end [value / pageid],
tl.resource_subtype, request_mode, request_type, request_status, request_session_id --, pr.text--, pr.status, pr.cmd 
from sys.dm_tran_locks tl left outer join (
select p.object_id, container_id
from sys.allocation_units a 
inner join sys.partitions p
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (0,2) and a.container_id = p.hobt_id))a
on tl.resource_associated_entity_id = a.container_id)oo
--inner join sys.dm_exec_requests r
--on oo.request_session_id = r.session_id
--left outer join (select pp.spid, ss.text from sys.sysprocesses pp cross apply sys.dm_exec_sql_text(pp.sql_handle)ss) pr
--on oo.request_session_id = pr.spid
inner join sys.dm_exec_sessions ss
on oo.request_session_id = ss.session_id
left outer join sys.dm_exec_requests r
on oo.request_session_id = r.session_id
where resource_type in ('KEY','PAGE','OBJECT','APPLICATION')
--where request_session_id = 635
order by oo.request_session_id

--select spid, loginame, s.text from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s  where p.spid = 635

