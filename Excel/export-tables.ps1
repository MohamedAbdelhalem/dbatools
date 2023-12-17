$server = '172.20.182.1'
$database = 'DataProdMongoDB'
$path = 'G:\IE\'+$database+'_Tables.xlsx'
$query = "SELECT top 100 
schema_name(t.schema_id)+'.'+t.name table_name, 
substring(schema_name(t.schema_id)+'.'+replace(replace(replace(replace(t.name,':',''),' ',''),'[',''),']',''),1,25)+'_'+
cast(row_number() over(partition by substring(schema_name(t.schema_id)+'.'+replace(replace(replace(replace(t.name,':',''),' ',''),'[',''),']',''),1,25) 
order by schema_name(t.schema_id)+'.'+replace(replace(replace(replace(t.name,':',''),' ',''),'[',''),']','')) as varchar(10)) sheet_name 
from sys.tables t inner join sys.objects o
on t.object_id = o.object_id
where o.type_desc = 'user_table'";
$queryResult = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $query;

for ($tid = 0; $tid -le $queryResult.count - 1; $tid++) 
    {
        $query = "select top 10 * from "+$database+"."+$queryResult.table_name[$tid]
        #$query
        Write-Progress -PercentComplete (($tid / $queryResult.count)*100.0) -Status "Waiting" -Activity "Exporting tables"
        Send-SQLDataToExcel -MsSQLserver -Connection $server -SQL $query -AutoNameRange -BoldTopRow -CellStyleSB {$True} -Path $path -WorkSheetname $queryResult.sheet_name[$tid]
    }

