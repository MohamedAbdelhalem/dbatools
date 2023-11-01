--Failover to node 3
--do not forget to enable SQLCMD mode in the SSMS
:CONNECT 10.55.20.1

ALTER AVAILABILITY GROUP [ag_SQLApp] FAILOVER;
