CREATE Procedure [dbo].[XEvent_errors]
(@spid varchar(10), @create bit = 1)
as
begin
declare 
@sql_create varchar(max) = 'CREATE EVENT SESSION [Restore_Error_Handling_spid_'+@spid+'] ON SERVER 
ADD EVENT sqlserver.error_reported(
    WHERE ([package0].[not_equal_int64]([error_number],(5703)) 
	AND [package0].[not_equal_int64]([error_number],(5701)) 
	AND [sqlserver].[session_id]=('+@spid+')))
ADD TARGET package0.ring_buffer
WITH (
MAX_MEMORY=4096 KB,
EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,
STARTUP_STATE=OFF)',
@exec	  varchar(max) = 'ALTER EVENT SESSION [Restore_Error_Handling_spid_'+@spid+'] ON SERVER STATE=START',
@sql_drop varchar(max) = 'DROP EVENT SESSION [Restore_Error_Handling_spid_'+@spid+'] ON SERVER' 

if @create = 1
begin
exec(@sql_create)
exec(@exec)
end
else
begin
exec(@sql_drop)
end

end

go
