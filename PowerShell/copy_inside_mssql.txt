Param(
    [Parameter(Mandatory=$True)]
    [String] $PPathFrom,
    [Parameter(Mandatory=$True)]
    [String] $PPathTo
)

Function File-Transfer-MSSQLSERVER 
{
param([int]$speed_MB, [string]$PathFrom, [string]$PathTo)
$ffile = [io.file]::OpenRead($PathFrom)
$tofile = [io.file]::OpenWrite($PathTo)

$total_bytes = (((get-item $PathFrom).Length/1MB) * 1024 *1024)
$startDate = (Get-Date)
[datetime]$date = "2023-01-01 00:00:00"

$query = 'DELETE FROM [dbo].[Copy_Progress]'
Invoke-Sqlcmd -ServerInstance '10.36.1.229' -Database master -Query $query;
$query = 'Insert Into [dbo].[Copy_Progress] Values ('''', '''', '''')'
Invoke-Sqlcmd -ServerInstance '10.36.1.229' -Database master -Query $query;

try {
    [byte[]]$buff = new-object byte[] ($speed_MB * 1MB) # speed by MB
    [long]$total = [int]$count = 0
    do {
        $count = $ffile.Read($buff, 0, $buff.Length)
        $tofile.Write($buff, 0, $count)
        $total += $count

        $seconds = ((Get-Date) - $startDate).totalSeconds
        $second_to_complete = ((100.0 / (($total/$total_bytes)*100.0)) * $seconds) - $seconds
        $time_to_complet = $date.AddSeconds($second_to_complete)
        [string]$print_time = $time_to_complet.ToString('HH:mm:ss') 

        $percent_complete = [math]::round((($total/$total_bytes)*100.0),3).ToString()+'%'

        $query = 'UPDATE [dbo].[Copy_Progress] SET [File_Name] = '''+$PathTo+''', [Percent_Complete] = '''+$percent_complete+''', [Time_to_Complete] = '''+$print_time+''''
	Invoke-Sqlcmd -ServerInstance '10.36.1.229' -Database master -Query $query;

        } 
    while ($count -gt 0)
       } finally {
         $ffile.Dispose()
         $tofile.Dispose()
     }
     $endDate = (Get-Date)
     "The copy total time duration is "+$date.AddMilliseconds(($endDate - $startDate).TotalMilliseconds).ToString('HH:mm:ss.fff')

     $query = 'DELETE FROM [dbo].[Copy_Progress]'
     Invoke-Sqlcmd -ServerInstance '10.36.1.229' -Database master -Query $query;
}

File-Transfer-MSSQLSERVER -speed_MB 18 -PathFrom $PPathFrom -PathTo $PPathTo

