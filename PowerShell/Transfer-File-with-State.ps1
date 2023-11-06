Function File-Transfer-with-state {
    param( [string]$filename, [string]$PathFrom, [string]$PathTo)
        $full_from_file = $PathFrom+"\"+$filename
        $full_to_file = $Pathto+"\"+$filename
        $ffile = [io.file]::OpenRead($full_from_file)
        $tofile = [io.file]::OpenWrite($full_to_file)

        $byteData = Get-Content -Path $full_from_file -Encoding Byte -ReadCount 0 -Raw | foreach { $_ }
        $total_bytes = $byteData.Count

        "Copy from ""$full_from_file"" to ""$full_to_file"" shows with below progress state."
        ""
        try {
                [byte[]]$buff = new-object byte[] 262144 #256 kb speed
                [long]$total = [int]$count = 0
                do {
                    #[string][math]::round(($total/$total_bytes) * 100.0,1) +"%"
                    Write-Progress -PercentComplete ($total/$total_bytes*100) -Status "Coping file progress" -Activity "Item $item of $total_bytes"

                    $count = $ffile.Read($buff, 0, $buff.Length)
                    $tofile.Write($buff, 0, $count)
                    $total += $count
        
                    } while ($count -gt 0)
            } finally {
            $ffile.Dispose()
            $tofile.Dispose()
                       }
    }

File-Transfer-with-state -filename 'SSMS-Setup-ENU.exe' -PathFrom 'C:\temp\new\' -PathTo '\\domain.com\DB\Backup'

