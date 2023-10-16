select [Transaction ID] from sys.fn_dblog(null,null)
where [transaction name] = 'delete'

select top 10 * from sys.fn_dblog(null,null)
where [Transaction ID] in (select top 1 [Transaction ID] from sys.fn_dblog(null,null)
where [transaction name] = 'delete')

dbo.F_BAB_T_ATMFT_IN.PK_F_BAB_T_ATMFT_IN
