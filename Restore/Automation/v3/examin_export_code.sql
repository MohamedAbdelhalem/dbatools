select 
AL_REQUEST,
AL_RESPONSE,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_REQUEST,'</') where value like '%<CIF>%') CIF,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_REQUEST,'</') where value like '%<MsgFrmt>%') message_format,
(select top 1 case when master.dbo.virtical_array(value,'>',3) like 'SA%' then master.dbo.virtical_array(value,'>',3) else master.dbo.virtical_array(value,'>',4) end from master.dbo.Separator(AL_REQUEST,'</') where value like '%<IBAN>%') IBAN,
(select top 1 case when master.dbo.virtical_array(value,'>',3) like '%<%>%' then master.dbo.virtical_array(value,'>',3) else master.dbo.virtical_array(value,'>',4) end from master.dbo.Separator(AL_REQUEST,'</') where value like '%<Source_Acct_No>%') Account_no,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_RESPONSE,'</') where value like '%<BE_Ref_No>%') Reference_no,
(select top 1 master.dbo.virtical_array(value,'>',3) from master.dbo.Separator(AL_RESPONSE,'</') where value like '%<IPS_TrxId>%') IPS_TrxId
from Reporting.dbo.anti_fraud 
where AL_ID in(4215052909)

declare @AL_REQUEST nvarchar(max) = N'<EAIMessage><EAIHeader><CIF>73470743</CIF><Lang>A</Lang><ChnlId>RMB</ChnlId><FunctnId>113017</FunctnId><Rqstr_Info1></Rqstr_Info1><Rqstr_Info2></Rqstr_Info2><Rqstr_Info3></Rqstr_Info3><EAIRtrnCd>000000</EAIRtrnCd><EAIRtrnCdDesc>Successful Operation</EAIRtrnCdDesc><BE_Ref_No>73470743</BE_Ref_No><MsgFrmt>Updt_Chrg_Card_Info_Rply_Msg</MsgFrmt></EAIHeader><Body><Stts>C73470743</Stts></Body></EAIMessage>'
declare @AL_RESPONSE nvarchar(max) = N'<EAIMessage><EAIHeader><CIF>73470743</CIF><Lang>A</Lang><ChnlId>RMB</ChnlId><FunctnId>113017</FunctnId><Rqstr_Info1></Rqstr_Info1><Rqstr_Info2></Rqstr_Info2><Rqstr_Info3></Rqstr_Info3><EAIRtrnCd>000000</EAIRtrnCd><EAIRtrnCdDesc>Successful Operation</EAIRtrnCdDesc><BE_Ref_No>73470743</BE_Ref_No><MsgFrmt>Updt_Chrg_Card_Info_Rply_Msg</MsgFrmt></EAIHeader><Body><Stts>C73470743</Stts></Body></EAIMessage>'

select master.dbo.virtical_array(value,'>',3), value
from master.dbo.Separator(@AL_REQUEST,'</') 
where value like '%<BE_Ref_No>%'

select master.dbo.virtical_array(value,'>',3), value
from master.dbo.Separator(@AL_RESPONSE,'</') 
where value like '%<BE_Ref_No>%'

select sum(row) from (
select count(*) row, AL_CIF from anti_fraud group by AL_CIF having count(*) >= 1000
order by row
)a 
