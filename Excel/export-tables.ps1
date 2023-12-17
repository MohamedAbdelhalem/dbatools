$server = '10.0.10.2'
$database = 'prodAPPschema'
$path = 'G:\IE\'+$database+'_Tables.xlsx'
$query = "select
schema_name(t.schema_id)+'.'+t.name table_name, 
substring(schema_name(t.schema_id)+'.'+replace(replace(replace(replace(t.name,':',''),' ',''),'[',''),']',''),1,25)+'_'+
cast(row_number() over(partition by substring(schema_name(t.schema_id)+'.'+replace(replace(replace(replace(t.name,':',''),' ',''),'[',''),']',''),1,25) 
order by schema_name(t.schema_id)+'.'+replace(replace(replace(replace(t.name,':',''),' ',''),'[',''),']','')) as varchar(10)) sheet_name 
from sys.tables t inner join sys.objects o
on t.object_id = o.object_id
where o.type_desc = 'user_table'";
$queryResult = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $query;

$queryResult 
for ($tid = 0; $tid -le $queryResult.count - 1; $tid++) 
    {
        $query = "select top 10 * from "+$database+"."+$queryResult.table_name[$tid]
        #$query
        Send-SQLDataToExcel -MsSQLserver -Connection $server -SQL $query -AutoNameRange -BoldTopRow -CellStyleSB {$True} -Path $path -WorkSheetname $queryResult.sheet_name[$tid]
    }

