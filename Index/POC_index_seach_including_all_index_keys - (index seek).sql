set statistics io on
set statistics profile on

select top 100000 RECID, XMLRECORD into [dbo].[FBNK_BAB_CARD_ISSUE_TEST]
from [dbo].[FBNK_BAB_CARD_ISSUE]


ALTER TABLE [dbo].[FBNK_BAB_CARD_ISSUE_TEST] 
ADD 
[ACCOUNT_NUMBER]	AS ([dbo].[FBNK_BAB_CARD_ISSUE_c3]([XMLRECORD])),
[CORP_CIF]			AS ([dbo].[FBNK_BAB_CARD_ISSUE_c47]([XMLRECORD])),
[CUSTOMER]			AS ([dbo].[FBNK_BAB_CARD_ISSUE_c4]([XMLRECORD])),
[NEXT_REVIEW_DATE]  AS ([dbo].[FBNK_BAB_CARD_ISSUE_c54]([XMLRECORD])),
[REPLACEMENT_DATE]  AS ([dbo].[FBNK_BAB_CARD_ISSUE_c36]([XMLRECORD])),
[ISSUE_DATE]		AS ([dbo].[FBNK_BAB_CARD_ISSUE_c15]([XMLRECORD]))

ALTER TABLE [dbo].[FBNK_BAB_CARD_ISSUE_TEST] 
ADD
CONSTRAINT [PK_FBNK_BAB_CARD_ISSUE_TEST] PRIMARY KEY CLUSTERED ([RECID] ASC)

drop index NCIndex_COMPUTE_FBNK_BAB_CARD_ISSUE_TEST on [dbo].[FBNK_BAB_CARD_ISSUE_TEST] 
create nonclustered index NCIndex_COMPUTE_FBNK_BAB_CARD_ISSUE_TEST on [dbo].[FBNK_BAB_CARD_ISSUE_TEST] ([ACCOUNT_NUMBER],[CUSTOMER],[ISSUE_DATE])


--missing index and Index Scan the NonClustered index 92%
select RECID 
from [dbo].[V_FBNK_BAB_CARD_ISSUE_TEST] 
where (Customer = 10030495)
order by [ACCOUNT_NUMBER] 

--missing index but Index Seek the NonClustered index 92%
select RECID
from [dbo].[V_FBNK_BAB_CARD_ISSUE_TEST] 
where (account_number >= 0
and Customer = 10030495)
order by [ACCOUNT_NUMBER] 

--Index Seek the NonClustered index 100%
select RECID 
from [dbo].[V_FBNK_BAB_CARD_ISSUE_TEST] 
where account_number = 921100272070008
