Set-DtcNetworkSetting -DtcName "Local" -AuthenticationLevel NoAuth -Confirm:$false
Set-DtcNetworkSetting -DtcName "Local" -InboundTransactionsEnabled 1 -Confirm:$false
Set-DtcNetworkSetting -DtcName "Local" -OutboundTransactionsEnabled 1 -Confirm:$false
Set-DtcNetworkSetting -DtcName "Local" -RemoteClientAccessEnabled 1 -Confirm:$false
Set-DtcNetworkSetting -DtcName "Local" -RemoteAdministrationAccessEnabled 1 -Confirm:$false
Set-DtcNetworkSetting -DtcName "Local" -XATransactionsEnabled 1 -Confirm:$false
Set-DtcNetworkSetting -DtcName "Local" -LUTransactionsEnabled 1 -Confirm:$false


