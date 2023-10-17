declare @RECID varchar(255), @XMLRECORD nvarchar(max), @ORCLFILENAME nvarchar(300), @ISBLOB varchar(1)
declare i cursor fast_forward
for
select RECID, XMLRECORD, ORCLFILENAME, ISBLOB
from tafj_voc
where recid in ('pp.in')

open i
fetch next from i into @RECID, @XMLRECORD, @ORCLFILENAME, @ISBLOB 
while @@FETCH_STATUS = 0
begin

update [10.38.5.65].T24PROD_UAT.dbo.tafj_voc
set 
RECID = @RECID, 
XMLRECORD = @XMLRECORD, 
ORCLFILENAME = @ORCLFILENAME,
ISBLOB = @ISBLOB 
where RECID = @RECID

fetch next from i into @RECID, @XMLRECORD, @ORCLFILENAME, @ISBLOB 
end
close i
deallocate i
