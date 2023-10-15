select i.name, ss.* 
from sys.dm_db_index_usage_stats ss inner join sys.indexes i
on i.object_id = ss.object_id
and i.index_id = ss.index_id
where ss.object_id = object_id('[dbo].[Invoices]')

exec sp_table_indexes '[dbo].[Invoices]'
--INX_Invoices_Invc_buyr_cif
--INX_Invoices_Invc_buyr_id
--INX_Invoices_Invc_no
--INX_Invoices_Invc_trx_no
--INX_Invoices_Invc_cif_trx_invc_no_iss_dt
--INX_Invoices_invc_trx_no_vat_amt

--used
--INX_Invoices_Invc_invc_no_cif_trx_iss_dt
--INX_Invoices_invc_crt_dt

select * from sys.allocation_units a inner join sys.partitions p
on (a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type in (2) and a.container_id = p.partition_id)
where p.object_id = object_id('[dbo].[Invoices]')


