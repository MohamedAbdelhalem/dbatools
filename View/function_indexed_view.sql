USE [T24PROD_UAT]
GO

/****** Object:  View [dbo].[V_FBNK_BAB_VISA_CRD_ISSUE]    Script Date: 2/6/2023 1:03:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_test_xml] 
WITH SCHEMABINDING 
AS
SELECT 
RECID ,RECID [VISA_CARDS_REFNO], [dbo].[F_BAB_H_INACTIVE_AC_c1](XMLRECORD) [ACTION_CODE]
FROM 
[dbo].[FBNK_BAB_VISA_CRD_ISSUE]

set statistics profile on

CREATE UNIQUE CLUSTERED INDEX IX_VIEW_V_test_xml 
	ON V_test_xml
	 ([RECID])

CREATE UNIQUE CLUSTERED INDEX IX_VIEW_V_test_xml2 
ON V_test_xml2
([RECID])
