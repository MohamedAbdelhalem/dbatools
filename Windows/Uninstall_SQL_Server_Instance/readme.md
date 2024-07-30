If you have an instance that you want to decommission it/them but you face an issue and you are not able to proceed.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/Manual_Remove_instance.png)

You can use **msiinv.exe** app to gather all product codes of the above uninstall Programs.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/download_msiinv.png)

Here are all products information printed out to an external file named **sql_products.txt**

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/msiinv_sql_products.png)

open the script product.sql into any SQL Server instance and copy the result of the file **sql_products.txt** into the **@sql** variable.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/past_msiinv_result_into_get_product_code_select_version.png)

Open **regedit** and go to **\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server** 

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_01.png)

and *right click* find, then past the product_code then click *Find Next*

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_02.png)

From the down path, you will see the instance that belongs to this code.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_03.png)

Then find in the SQL Script **get_product_codes.sql** to locat you on the product code, then update the name and add **- instance name**

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_04.png)

After adding the right instance name beside the product name, when you execute the script again you will see it has been reflected down there.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_05.png)

After adding and updating all products, all changes have been reflected. Now you can **choose** the instance(s) that you want to remove.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_final01.png)

I've updated the sql script to add another column and to just copy the column result of column **msiexec_delete_service** in PowerShell to remove the specific product(s). 

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/find_product_code_final02.png)

Open **PowerShell as Administrator** and copy the column **msiexec_delete_service** that belongs to a specific instance.
powershell
```
msiexec /x "{DB570D37-60D8-4D12-A7AB-11482EA5FE8A}"
```
and then *click* Yes on **Windows Installer**

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/msiexec_01.png)

and here is the exact instance product(s), and you may see one code for **SQL Server** (*Instance Name*) plus the **CEIP** or one code for each one.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/msiexec_02.png)


![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/msiexec_03.png)

Now, go to the services and you will indicate that it has been stopped (SQL Server Engine and the Agent).

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/droped_service_indecator.png)

then to remove the removed services from **services.msc**, open **CMD as Administrator** and then execute these script but replace the right values, as the below example:

powershell
```
powershell
get-service -name "*sql*" | where {$_.status -eq "stopped"} select @{name="name"; expression={"sc.exe delete "+$_.name}}

exit

sc.exe delete SQLAgent$MSSQL2016_03

sc.exe delete MSSQL$MSSQL2016_03
```

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/delete_service_sc.png)

and finally the services have been removed.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Windows/Uninstall_SQL_Server_Instance/gallery/delete_service_sc_final.png)

