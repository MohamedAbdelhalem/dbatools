declare @AL_ID bigint
declare i cursor fast_forward
for
select AL_ID
from [anti_fraud]
where AL_CIF in 
(13716017,11588500,12025571,13795736,37779982,13079293,37920668,12772130,37677738,10779091,10746051,71496659,37753881,13801202,13783826,13789118,13259605,37247234,37431507,11898106,70178302,37548792,13779108,53193510,70472353,13699337,12194803,63025697,57556539,64747824,10311214,10232382,13661906,37708558,73125560,37402314,37777731,37809596,13156296,10766960,37418873,37608275,12056461,13524846,63804008,12036178,37704271,12464720,13790702,63012565,12568280,37634613,50287666,13206317,56575708,13757901,10794372,13401896)
and AL_ID not in (select AL_ID from CIF_Data_final)
order by AL_ID

open i
fetch next from i into @AL_ID
while @@FETCH_STATUS = 0
begin

insert into dbo.CIF_Data_final
select 
[AL_ID],
[O_ID],
[AL_CIF],
[AL_LOGON_ID],
--AL_REQUEST,
--AL_RESPONSE,
--(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_REQUEST,'</') where value like '%<CIF>%') CIF,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_REQUEST,'</') where value like '%<MsgFrmt>%') message_format,
(select top 1 case when master.dbo.virtical_array(value,'>',3) like 'SA%' then master.dbo.virtical_array(value,'>',3) else master.dbo.virtical_array(value,'>',4) end from master.dbo.Separator(AL_REQUEST,'</') where value like '%<IBAN>%') IBAN,
(select top 1 case when master.dbo.virtical_array(value,'>',3) like '%<%>%' then master.dbo.virtical_array(value,'>',3) else master.dbo.virtical_array(value,'>',4) end from master.dbo.Separator(AL_REQUEST,'</') where value like '%<Source_Acct_No>%') Account_no,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_RESPONSE,'</') where value like '%<BE_Ref_No>%') Reference_no,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_RESPONSE,'</') where value like '%<IPS_TrxId>%') IPS_TrxId,
[AL_IP_CLIENT],
[AL_IP_LB], 
[AL_IP_SERVER],
AL_SESSION_ID,
[AL_START_TS],
[AL_END_TS],
[AL_INFO_1],
[AL_INFO_2]
from [Reporting].[dbo].[anti_fraud]
where AL_ID = @AL_ID

fetch next from i into @AL_ID
end
close i
deallocate i
