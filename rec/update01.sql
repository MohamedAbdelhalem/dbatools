select Operation, Context, [Page ID], [Transaction ID], AllocUnitName, 
[RowLog Contents 0], 
[RowLog Contents 1], 
[RowLog Contents 2], 
[RowLog Contents 3], 
[RowLog Contents 4] 
from sys.fn_dblog(null,null)
where Operation = 'LOP_MODIFY_COLUMNS'
--and [Transaction ID] in ('0000:00001045','0000:0000103f','0000:00001026','0000:00001027','0000:00001028','0000:0000102d','0000:00001033','0000:0000103a')
select convert(int,0x0091)
--0xB000 0000 A90C0000 49736D61696C20004A0004054E030000
declare @row varchar(max) = '70000c0001000000f938000004000002009100a9005300610075006400690020004100720061006200690061002c0020005200690079006100640068002c00200041006c0045007a00640069006800610072002c0020003300330033003200200041006c00410062006100730073002000620069006e00200041006200640065006c006d006f00740061006c00690062004d6f68616d6564204661777a7920416264656c68616c656d00000000000000004e1000000000000000000000000000000000'
declare @mod varchar(max) = 'B0000000A90C000049736D61696C20004A0004054E030000'

select (convert(int, 0x009F)*2), len(@row), len(@row) , (convert(int, 0x00B8)*2)- (convert(int, 0x00B1)*2)
select substring(@row,(convert(int, 0x009F)*2)+1, len(@row) - (convert(int, 0x00B8)*2) - 2)
select substring(@row,(convert(int, 0x0013)*2)+1, 1000)
select substring(@mod,16+1,(convert(int, 0x00B8)*2)- (convert(int, 0x00B1)*2))

select convert(varchar(max),0x49736D61696C20)
