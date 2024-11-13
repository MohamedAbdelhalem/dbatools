SELECT SERVERPROPERTY('machinename') 
AS 'Server Name', 
ISNULL(SERVERPROPERTY ('instancename'), 
SERVERPROPERTY ('machinename')) AS 'Instance Name', 
name AS 'Login With Password Equal to Login Name' 
FROM master.sys.sql_logins 
WHERE PWDCOMPARE(name,password_hash)=1 
ORDER BY name 
