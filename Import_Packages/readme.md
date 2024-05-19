SQL Server PowerShell
https://www.powershellgallery.com/packages/SqlServer/22.1.1


``` error
Import-Module : File C:\Users\Moham\OneDrive\Documents\WindowsPowerShell\Modules\SqlServer\22.2.0\SqlNotebook.psm1 cannot be loaded because running scripts is disabled 
on this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.
```

1. First, Open **PowerShell** with **Run as Administrator**.
2. Then, run this command in PowerShell
``` Powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
3. After that type ``` Y ``` and press Enter.
