declare 
@id int,
@min_RECID varchar(255),
@max_RECID varchar(255)

declare i cursor fast_forward
for
select id, s.min_RECID, s.max_RECID
from master.dbo.FENJ_FUND200_summary s
where inserted = 0

open i
fetch next from i into @id, @min_RECID, @max_RECID
while @@FETCH_STATUS = 0
begin

insert into [dbo].[FENJ.FT_CONV_31MAR]
([RECID], [XMLRECORD], [PROCESSING_DATE], [AUTH_DATE])
select [RECID], [XMLRECORD], [PROCESSING_DATE], [AUTH_DATE]
from [T24SDC3].[dbo].[FENJ_FUND200]
where RECID between @min_RECID and @max_RECID

update master.dbo.FENJ_FUND200_summary set inserted = 1 where id = @id

fetch next from i into @id, @min_RECID, @max_RECID
end
close i
deallocate i
