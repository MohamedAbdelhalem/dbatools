set identity_insert middleware_requests_summary2 on

insert into [master].[dbo].[middleware_requests_summary2](
[id],[unique_id],[from_id],[to_id],[from_unique_column],[to_unique_column],[date_time],[deleted])
select 
[id],[unique_id],[from_id],[to_id],[from_unique_column],[to_unique_column],[date_time],[deleted]
from [10.36.1.212,17120].[master].[dbo].[middleware_requests_summary2]
where deleted = 0 
and unique_id = 1
and id > (select max(id) from [master].[dbo].[middleware_requests_summary2])

set identity_insert middleware_requests_summary2 off
