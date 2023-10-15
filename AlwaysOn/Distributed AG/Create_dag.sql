--on the PRIMARY node node 1 
CREATE AVAILABILITY GROUP [DAG_Test]  
   WITH (DISTRIBUTED)   
   AVAILABILITY GROUP ON  
      'AG_Test_01' WITH    
      (   
         LISTENER_URL = 'tcp://VPRACDNS_P004.ALBILAD.com:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL   
      ),   
      'AG_Test_02' WITH    
      (   
         LISTENER_URL = 'tcp://VPRACDNS_P002.ALBILAD.com:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL   
      );    
GO   

--on the PRIMARY node node 3 on the SECONDARY site 
ALTER AVAILABILITY GROUP [DAG_Test]   
   JOIN   
   AVAILABILITY GROUP ON  
      'AG_Test_01' WITH    
      (   
		 LISTENER_URL = 'tcp://VPRACDNS_P004.ALBILAD.com:5022',       
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL   
      ),   
      'AG_Test_02' WITH    
      (   
         LISTENER_URL = 'tcp://VPRACDNS_P002.ALBILAD.com:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = MANUAL   
      );    
GO  