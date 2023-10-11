declare 
@dtc_exec varchar(1000)

set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -AuthenticationLevel NoAuth -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)
set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -InboundTransactionsEnabled 1 -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)
set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -OutboundTransactionsEnabled 1 -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)
set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -RemoteClientAccessEnabled 1 -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)
set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -RemoteAdministrationAccessEnabled 1 -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)
set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -XATransactionsEnabled 1 -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)
set @dtc_exec = 'xp_cmdshell ''PowerShell.exe -Command "& {Set-DtcNetworkSetting -DtcName "Local" -LUTransactionsEnabled 1 -Confirm:$false}"'''
print(@dtc_exec)
exec (@dtc_exec)


