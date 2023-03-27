SELECT member_name, member_state_desc, member_type_desc, number_of_quorum_votes, 
case 
when left(member_name,2) in ('D1','Fi') and member_state = 1 and number_of_quorum_votes = 1 then 'OK' 
when left(member_name,2) = 'D2' and member_state = 1 and number_of_quorum_votes = 1 and (select count(*) from sys.dm_hadr_cluster_members where number_of_quorum_votes = 1) % 2 = 1 then 'OK' 
when left(member_name,2) = 'D2' and member_state = 1 and number_of_quorum_votes = 0 and (select count(*) from sys.dm_hadr_cluster_members where number_of_quorum_votes = 1) % 2 = 1 and count(*) over() > 3 then 'OK' 
else 'NO' end
from sys.dm_hadr_cluster_members
order by member_name
