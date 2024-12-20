Consider demoing the following:

Server name: SQLProdN1

Login to SQLProdN1 Virtual Environment
Follow the below instructions to install and configure the certificate for the SQL server instance.
Test connection using Encrypted Connection option
View the DMV to confirm the connections are encrypted.

To create a certificate, use the following PowerShell command. 
```powershell
New-SelfSignedCertificate –DNSName SQLN2.CORPNET.CONTOSO.com –CertStoreLocation Cert:\LocalMachine\My –FriendlyName SQLcertificate –KeySpec KeyExchange
```

To install and configure certificate for SQL Server instance

 On SQLN2 Open SQL Server Configuration Manager and in the console pane, expand SQL Server Network Configuration.
 Right-click Protocols for MSSQLSERVER and then select Properties.
 Choose the Certificate tab, and in the Certificate: drop down box, select the SQLCertificate.
 Click Ok to the message on “Any changes made will be saved, however they will not take effect until the service is stopped and restarted).
9. You should see the Certificate installed in Certificate tab with name SQLN2.SQLSecurity.local
10. On the Flags tab, in the ForceEncryption box, select Yes, and then click OK to close the dialog box.
11. Restart the SQL Server service.

If the SQL Server service does not start, assign permission to the local service account.
In the search bar type, "certmgr" wrong- certlm.msc , and the select Manage computer certificates
Select Personal and then Certificates. 
Right-click the "SQLN2" wrong "SQLcertificate" certificate, select All Tasks and then Manage Private Keys.
Add corpnet\SQLN2_SVC in the security box with Full Control.
Click OK and try return to Configuration Manager to restart SQL Server service.


To Test connection using Encrypt Connection option

Open SSMS -> Options -> Connection Properties -> Encrypt connection (Enable the Checkbox)
In server name type SQLN2.corpnet.contoso.com
Connect to the SQL Server instance

To view DMV for confirming the connections are encrypted

1. View sys.dm_exec_connections to review connection information and confirm connections are encrypted.

SELECT session_id, net_transport, encrypt_option, client_net_address FROM sys.dm_exec_connections

The encrypt_option column will contain value TRUE indicating that the connections are encrypted.



