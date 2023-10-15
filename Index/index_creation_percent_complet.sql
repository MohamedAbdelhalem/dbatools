--show down all indexes with the current index create step
select id, script, case which_one when 1 then current_script else '' end current_script
from (
select sp.id, sp.value script, substring(s.text, p.stmt_start/2+1, p.stmt_end/2 - p.stmt_start/2) current_script,
case when master.dbo.vertical_array(sp.value,' ',4) = master.dbo.vertical_array(substring(s.text, p.stmt_start/2+1, p.stmt_end/2 - p.stmt_start/2),' ',4) then 1 else 0 end which_one
from sys.sysprocesses p 
cross apply sys.dm_exec_sql_text(p.sql_handle)s
cross apply master.dbo.Separator(s.text,char(10))sp
where p.spid = 97)a
order by id

--index creation percent complet
select cast(cast(id as float) / cast(count_all as float) * 100.0 as numeric(10,2)) index_creation_percent_complet
from (
select top 100 percent sp.id, sp.value, --s.text, substring(s.text, p.stmt_start/2+1, p.stmt_end/2 - p.stmt_start/2),
case when master.dbo.vertical_array(sp.value,' ',4) = master.dbo.vertical_array(substring(s.text, p.stmt_start/2+1, p.stmt_end/2 - p.stmt_start/2),' ',4) then 1 else 0 end which_one, count(*) over() count_all
from sys.sysprocesses p 
cross apply sys.dm_exec_sql_text(p.sql_handle)s
cross apply master.dbo.Separator(s.text,char(10))sp
where p.spid = 97
order by sp.id)b
where which_one = 1

--CREATE NONCLUSTERED INDEX [Ind_AUTH_DATE_FBNK_FUNDS_TRANSFER#HIS_old_c153] ON [dbo].[FBNK_FUNDS_TRANSFER#HIS_old]([AUTH_DATE]
--CREATE NONCLUSTERED INDEX [Ind_PROCESSING_DATE_FBNK_FUNDS_TRANSFER#HIS_full_old_c18] ON [dbo].[FBNK_FUNDS_TRANSFER#HIS_full_old]([PROCESSING_DATE]