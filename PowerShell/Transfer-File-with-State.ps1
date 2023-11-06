Function File-Transfer-with-state 
{
param( [string]$filename, [int]$speed_MB, [string]$PathFrom, [string]$PathTo)
$full_from_file = $PathFrom+"\"+$filename
$full_to_file = $Pathto+"\"+$filename
$ffile = [io.file]::OpenRead($full_from_file)
$tofile = [io.file]::OpenWrite($full_to_file)

$total_bytes = (((get-item $full_from_file).Length/1MB) * 1024 *1024)

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
        Write-Progress -PercentComplete (($total/$total_bytes)*100.0) -Status "In-progress..." -Activity "Coping file progress"
        } 
    while ($count -gt 0)
       } finally {
         $ffile.Dispose()
         $tofile.Dispose()
     }
}

File-Transfer-with-state -filename 'T24SDC3_HIS_conv_2023_09_14__01_13_pm.bak' -speed_MB 4 -PathFrom 'N:\must_delete' -PathTo 'N:\must_delete_temp'


