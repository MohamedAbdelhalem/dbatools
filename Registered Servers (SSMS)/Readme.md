If you want to register your database servers and you don't have much time to organize or you have a lot of decommissioned servers you can use this script.

Location 
C:\Users\your username\AppData\Roaming\Microsoft\Microsoft SQL Server\120\Tools\Shell\RegSrvr.XML

# Tips: #
- This folder "C:\Users\your username\AppData" is by default hidden.
- If you have an old version of SSMS like 2014 and then you install a new one 18, it will use the same location.
- after you execute the RegSrvr.sql file with your required database servers then do the below steps in case you already have registered servers:
- 1, go to any servers, delete the content of this file ...\Microsoft SQL Server\120\Tools\Shell\RegSrvr.XML, and add the result.
- 2, export the Local Server Groups if you added multiple groups or just export the group if you have only 1 group.
- 3, import the file "filename.regsrvr" into your Computer so that you can use it as a central place to manage your database servers.
- If you haven't used the registered servers before then delete the content of this file ...\Microsoft SQL Server\120\Tools\Shell\RegSrvr.XML on your PC, and add the result.
  
