The "**Log on as a service**" security policy in SQL Server allows a service account to log on to the system as a service. This is essential for SQL Server services to start and run properly. When this policy is assigned to a service account, it grants the account the necessary permissions to log on and operate as a service.

If the "Log on as a service" role is missing for a service account, the SQL Server services that rely on this account will fail to start. This can lead to various issues, such as the inability to access the SQL Server database, execute jobs, or perform automated tasks Essentially, the services will be unable to authenticate and run, causing disruptions in database operations.

If you encounter this issue, you can manually add the service account to the "Log on as a service" policy using the Local Security Policy tool (secpol.msc) on Windows.

The "**Replace a process-level token**" security policy in SQL Server allows a service account to replace the access token associated with a child process. This is crucial for certain operations where one service needs to start another service on behalf of a user. For example, the Task Scheduler uses this policy to manage tasks that require elevated privileges.

If this role is missing for a service account, the affected services may fail to start or perform specific tasks that require this privilege. This can lead to issues with automated tasks, scheduled jobs, and other operations that depend on the ability to replace process-level tokens.

To ensure smooth operation, you can manually add the service account to the "Replace a process-level token" policy using the Local Security Policy tool (secpol.msc) on Windows.

The "**Bypass traverse checking**" security policy in SQL Server allows a service account to navigate an object path in the NTFS file system or in the registry without being checked for the Traverse Folder special access permission. This means that the account can traverse folders to access permitted files or subfolders, but it does not allow the account to list the contents of a folder.

If this role is missing for a service account, the affected services may encounter issues when trying to access certain files or directories. This can lead to problems with automated tasks, scheduled jobs, and other operations that require access to specific paths.

To ensure smooth operation, you can manually add the service account to the "Bypass traverse checking" policy using the Local Security Policy tool (secpol.msc) on Windows.


The "**Adjust memory quotas for a process**" security policy in SQL Server allows a service account to change the maximum amount of memory that is available to a process. This is important for system tuning and ensuring that SQL Server can dynamically manage its memory usage based on the workload.

If this role is missing for a service account, SQL Server may encounter issues with memory management, leading to performance problems or even failure to start. This can affect the overall performance and stability of the SQL Server instance.

To ensure smooth operation, you can manually add the service account to the "Adjust memory quotas for a process" policy using the Local Security Policy tool (secpol.msc) on Windows.
