declare @tables varchar(max), @sql varchar(max)
set @tables = 'F_BAB_H_E260
F_BAB_H_EB_MNG_TXN_MAP
F_BAB_H_EB_NTFCN_EVNT
F_BAB_H_EB_PKG_FEE
F_BAB_H_EB_PKG_FEE#HIS
F_BAB_H_EB_PKG_FEE#NAU
F_BAB_H_EB_STATE#HIS'

select @tables =  replace(@tables,char(10),''',''')
select @tables = ''''+convert(varchar(max), replace(convert(varbinary(max), @tables),0x0D,''))+''''

set @sql = '
select table_name, column_name, data_type, master.dbo.format(rows,-1) rows
from (
select p.object_id, t.name table_name, max(rows) rows
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
group by p.object_id, t.name, t.schema_id)a inner join (
select t.object_id, c.name column_name, tp.name data_type
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
inner join sys.types tp 
on tp.user_type_id = c.user_type_id
where c.name = ''XMLRECORD'')b
on a.object_id = b.object_id
--where table_name in (SELECT orclfilename FROM [10.38.5.65].[T24PROD_UAT].dbo.TAFJ_VOC WHERE ISBLOB=''b'')
where table_name in ('+@tables+')
order by a.table_name'

exec(@sql)

