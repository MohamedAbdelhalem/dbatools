Function File-Transfer-with-state 
{
param( [string]$filename, [int]$speed_MB, [string]$PathFrom, [string]$PathTo)
$full_from_file = $PathFrom+"\"+$filename
$full_to_file = $Pathto+"\"+$filename
$ffile = [io.file]::OpenRead($full_from_file)
$tofile = [io.file]::OpenWrite($full_to_file)

$total_bytes = (((get-item $full_from_file).Length/1MB) * 1024 *1024)
$startDate = (Get-Date)
#[datetime]$time_to_complet
[datetime]$date = "2023-01-01 00:00:00"

"Copying file... 
from ""$full_from_file"" 
to ""$full_to_file""" 
""

try {
    [byte[]]$buff = new-object byte[] ($speed_MB * 1MB) # speed by MB
    [long]$total = [int]$count = 0
    do {
        #[string][math]::round(($total/$total_bytes) * 100.0,1) +"%"
        $count = $ffile.Read($buff, 0, $buff.Length)
        $tofile.Write($buff, 0, $count)
        $total += $count
        #cast((100.0 / (round(@percent_complete,15) + .00001)) * datediff(s, @start_time, getdate()) as int) - datediff(s, @start_time, getdate())
        $seconds = ((Get-Date) - $startDate).totalSeconds

        $second_to_complete = ((100.0 / (($total/$total_bytes)*100.0)) * $seconds) - $seconds
        $time_to_complet = $date.AddSeconds($second_to_complete)
        [string]$print_time = $time_to_complet.ToString('HH:mm:ss') 

        Write-Progress -PercentComplete (($total/$total_bytes)*100.0) -Status "waiting $print_time to complete" -Activity "Coping file $filename"
        } 
    while ($count -gt 0)
       } finally {
         $ffile.Dispose()
         $tofile.Dispose()
     }
}


File-Transfer-with-state -filename 'T24SDC3_HIS_conv_2023_09_14__01_13_pm.bak' -speed_MB 15 -PathFrom 'N:\must_delete' -PathTo 'N:\must_delete_temp'


