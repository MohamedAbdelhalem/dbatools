Function File-Transfer-with-state 
{
param( [string]$filename, [string]$PathFrom, [string]$PathTo)
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
    [byte[]]$buff = new-object byte[] 1048576 # 1 MB speed
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

File-Transfer-with-state -filename 'SSMS-Setup-ENU.exe' -PathFrom 'N:\must_delete' -PathTo 'N:\must_delete_temp'

