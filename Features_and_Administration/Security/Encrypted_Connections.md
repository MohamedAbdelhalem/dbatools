### How to configure a self-sign certificate and add it to the SQL Server instance.

**Server name:** `SQLProdN1`

a. Use the following PowerShell command to create the certificate. 
```powershell

New-SelfSignedCertificate –DNSName SQLProdN1.CORPNET.CONTOSO.com –CertStoreLocation Cert:\LocalMachine\My –FriendlyName SQLcertificate –KeySpec KeyExchange

```
b. To install and configure a certificate for the SQL Server instance.

1. Open SQL Server Configuration Manager, open run then type `sqlservermaanger16.msc` and in the console pane, expand SQL Server Network Configuration.
2. Right-click Protocols for MSSQLSERVER and then select Properties.
3. Choose the Certificate tab, and in the Certificate: drop down box, select the certificate name `SQLCertificate`.
4. Click Ok to the message on “Any changes made will be saved, however, they will not take effect until the service is stopped and restarted).
5. On the Flags tab, in the `ForceEncryption` box, select Yes, and then click OK to close the dialog box.
6. Restart the SQL Server service.

c. If the SQL Server service does not start, assign permission to the local service account.
1. In the search bar type, "certlm.msc", and then select Manage computer certificates
2. Select Personal and then Certificates. 
3. Right-click the "SQLCertificate" certificate, select All Tasks, and then Manage Private Keys.
4. Add `corpnet\SQLN2_SVC` in the security box with Full Control.
5. Click OK and return to the Configuration Manager to restart the SQL Server service.

d. To Test the connection using the Encrypt Connection option:

1. Open SSMS -> Options -> Connection Properties -> Encrypt connection (Enable the Checkbox)
2. In server name type SQLN2.corpnet.contoso.com
3. Connect to the SQL Server instance

- View sys.dm_exec_connections to review connection information and confirm connections are encrypted.
```SQL

SELECT session_id, net_transport, encrypt_option, client_net_address
FROM sys.dm_exec_connections
WHERE session_id = @@spid
 
--The encrypt_option column will contain the value TRUE indicating that the connections are encrypted.
````

