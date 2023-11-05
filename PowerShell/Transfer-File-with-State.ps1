function File-Transfer-with-states {
    param( [string]$originalFile, [string]$copyFile)
$ffile = [io.file]::OpenRead($originalFile)
$tofile = [io.file]::OpenWrite($copyFile)

$byteData = Get-Content -Path $filePath -Encoding Byte -ReadCount 0 -Raw | foreach { $_ }
$total_bytes = $byteData.Count
"Copy ""$filePath"" to ""$outputFile"" shows with below progress state."
""
try {
    [byte[]]$buff = new-object byte[] 4096
    [long]$total = [int]$count = 0
    do {
        [string][math]::round(($total/$total_bytes) * 100.0,1) +"%"
 
        $count = $ffile.Read($buff, 0, $buff.Length)
        $tofile.Write($buff, 0, $count)
        $total += $count
        
    } while ($count -gt 0)
} finally {
    $ffile.Dispose()
    $tofile.Dispose()
}
}

File-Transfer-with-states -originalFile 'C:\temp\Untitled_Recovered.gif' -copyFile 'K:\Backup\Untitled_Recovered.gif'

