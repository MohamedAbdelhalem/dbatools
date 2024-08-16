select 
row_number() over(order by function_name, scheme_name) id, 
row_number() over(partition by function_name order by function_name, scheme_name) scheme_id, 
function_name, ranges, scheme_name, filegroups
from (
select ps.function_id, ps.name scheme_name, count(*) filegroups
from sys.partition_schemes ps inner join sys.destination_data_spaces d
on ps.data_space_id = d.partition_scheme_id
group by ps.function_id, ps.name) f
inner join (
select pf.function_id, pf.name function_name, sum(case when prv.value is not null then 1 else 0 end) ranges
from sys.partition_range_values prv inner join sys.partition_functions pf
on prv.function_id = pf.function_id
group by pf.function_id, pf.name) s
on f.function_id = s.function_id
