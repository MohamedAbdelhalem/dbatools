$path = "G:\IE"
$packagePath = "importexcel.5.1.1.nupkg"
$packageName = $packagePath.Split(".")[0]
$packageVersion = $packagePath.Replace($packagePath.Split(".")[0]+".", "").Replace("."+$packagePath.Split(".")[-1], "")
$zip = $packagePath.Replace("."+$packagePath.Split(".")[-1],".zip")
$unzip = $path+"\"+$packageName+"."+$packageVersion

if ($packagePath -like "*."+$packagePath.Split(".")[-1])
    {
        Copy-Item -Path $path\$packagePath -Destination $path\$zip
        Expand-Archive -Path $path\$zip -DestinationPath $unzip
        $userLoc = $env:PSModulePath.Split(';')
        $UserModulePath = $userLoc | where {$_ -like "*\Users\*"}
        $checkPath = Test-Path $UserModulePath
        if ($checkPath -eq 0)
        {
           New-Item -Path $UserModulePath -ItemType Directory
        }
        New-Item -Path $UserModulePath\$packageName -ItemType Directory
        move-Item -Path $unzip -Destination $UserModulePath\$packageName\$packageVersion
    }
    else
    {
        Write-Output "This is not a package extension."
    }
