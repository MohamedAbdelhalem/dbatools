create table Employees  (id int, full_name varchar(100), salary int, address varchar(1000))
create table Employees1 (id int, full_name varchar(100), address varchar(1000), salary int)
create table Employees2 (id int, address varchar(1000), full_name varchar(100), salary int)
create table Employees3 (address varchar(1000), id int, full_name varchar(100), salary int)
create table Employees4 (address varchar(1000), id int, full_name varchar(100), salary int)
create table Employees5 (address varchar(1000), id int, full_name varchar(100), salary int)
create table Employees6 (address Nvarchar(1000), id int, full_name varchar(100), salary int)
create table Employees7 (address Nvarchar(1000), id int, full_name varchar(100), salary int)
create table Employees8 (address Nvarchar(1000), id int, full_name varchar(100), salary int)
create table Employees9 (address Nvarchar(1000), id int, full_name varchar(100), salary int)

insert into Employees  (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees1 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees2 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees3 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees4 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees5 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees6 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, NSaudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees7 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, NSaudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees8 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, NSaudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
insert into Employees9 (id, full_name, salary, address) values (1, Mohamed Fawzy Ismail Abdelhalem, 14585, NSaudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
update Employees  set address = Saudi Arabia, Riyadh, AlEzdihar, 3245 AlAbass Bin Abdelmotalib
update Employees1 set address = Saudi Arabia, Riyadh, AlEzdihar, 3245 AlAbass Bin Abdelmotalib
update Employees2 set address = Saudi Arabia, Riyadh, AlEzdihar, 3245 AlAbass Bin Abdelmotalib
update Employees3 set address = Saudi Arabia, Riyadh, AlEzdihar, 3245 AlAbass Bin Abdelmotalib
update Employees4 set address = Saudi Arabia, Riyadh, AlEzdEEEE, 3245 AlAbass Bin Abdelmotalib
update Employees5 set address = Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass Bin Abdelmotalib
update Employees6 set address = NSaudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass Bin Abdelmotalib
update Employees7 set address = NSaudi Arabia, Jedda, AlEzdihar, 3245 AlAbass Bin Abdulmotalib
update Employees8 set address = NSaudi Arabia, Jedda, AlEzdihar, 3245 AlAbass Bin Abdulmotalib
update Employees9 set full_name = Mohamed Fawzy Abdelhalem

update Employees set address = Saudi Arabia, Riyadh, AlEzdihar, 3266 AlAbass Tin Abdelmotalib, salary = 14500
0x0300 0B00 0500 0F000100
0x9100B0008F00AE005200690079006100640068004A00650064006400610058003300330032006C003200340035003D00620069006E0020004100620064006500420069006E00200041006200640075064106440645062000

select Operation, Context, [Page ID], [Transaction ID], AllocUnitName, 
[RowLog Contents 0], 
[RowLog Contents 1], 
[RowLog Contents 2], 
[RowLog Contents 3], 
[RowLog Contents 4] 
from sys.fn_dblog(null,null)
where Operation = LOP_MODIFY_COLUMNS
--and [Transaction ID] in (0000:00001045,0000:0000103f,0000:00001026,0000:00001027,0000:00001028,0000:0000102d,0000:00001033,0000:0000103a)
0xB0000000A90C000049736D61696C20004A0004054E030000
select convert(int,0x0091)
0xB000 0000 A90C0000 49736D61696C20004A0004054E030000
declare @row varchar(max) = 70000c0001000000f938000004000002009100a9005300610075006400690020004100720061006200690061002c0020005200690079006100640068002c00200041006c0045007a00640069006800610072002c0020003300330033003200200041006c00410062006100730073002000620069006e00200041006200640065006c006d006f00740061006c00690062004d6f68616d6564204661777a7920416264656c68616c656d00000000000000004e1000000000000000000000000000000000
select (convert(int, 0x009F)*2), len(@row), len(@row) , (convert(int, 0x009F)*2)
select substring(@row,(convert(int, 0x009F)*2)+1, 1000)
select substring(@row,(convert(int, 0x0013)*2)+1, 1000)


select substring(@row,
(convert(int, 0x009F)*2) + 1, len(@row) - (convert(int, 0x0013)*2)-(convert(int, 0x009F)*2))
select substring(@row,
(convert(int, 0x0031)*2) + 1, len(@row) - (convert(int, 0x0013)*2)-(convert(int, 0x009F)*2))
select substring(@row,
((convert(int, 0x009F)*2) - convert(int, 0x0013)*2) + 1, len(@row) - (convert(int, 0x0013)*2)-(convert(int, 0x009F)*2))
select (convert(int, 0x0013)*2), (convert(int, 0x009F)*2), ((convert(int, 0x00B8)*2)-(convert(int, 0x009F)*2)-(convert(int, 0x0013)*2))
select len(convert(varbinary(max),Mohamed Fawzy Ismail Abdelhalem)) * 2
select convert(varbinary(max),Mohamed Fawzy Abdelhalem,3)

select convert(varchar(1000), 0x416264656c68616c656d)
select convert(varchar(1000), 0x49736D61696C20)
select convert(nvarchar(1000), 0x320034003500200041006c00410062006100730073002000420069006e00200041006200640075006c006d006f00740061006c0069006200)
0x
33333220416C4162617373206200000032343520416C416261737320420000001D00000026000000
select convert(varchar(100),0x33333220416C41626173732062) 00000032343520416C416261737320420000001D00000026000000

70000c00
01000000
a4380000
0400
00
0200
3400
7200
4d6f68616d6564204661777a792049736d61696c20416264656c68616c656d5361756469204172616269612c205269796164682c20416c457a64696861722c203332363620416c41626173732054696e20416264656c6d6f74616c69620000000000000000cb0f00000000

0x
01 
01
00 
0C00 00D1
D9C83400000102000402030004

0x
 3333322 04 16C416261737320
 6200000032343520416C41626173732042970000C5003E00C8000000
33333332
33323435
select dbcc page(0,+cast(allocated_page_file_id as varchar(20))+,+ cast(allocated_page_page_id as varchar(20))+,3)
from sys.dm_db_database_page_allocations(db_id(), object_id(dbo.employees9),null,null,detailed)
where page_type_desc = data_page
dbcc page(0,1,608,3)
select convert(varbinary(max),3332)
select convert(varbinary(max),3245)
select convert(varbinary(max),bin)
select convert(varbinary(max),Bin)
select convert(varbinary(max),14585)
select convert(varchar(max),0x)
select convert(varchar(max),0x32343520416C41626173732042)
select convert(int,0xF9)
F9000000
A4000000

0x0101000C0000D1D9C83400000102000402030004
0xF9000000A4000000343520416C41626173732042363620416C41626173732054C8000000CB000000

dbcc traceon(3604)
dbcc page(0,1,376,3)

select convert(varbinary(max), Saudi Arabia, Riyadh, AlEzdihar, 3332 AlAbass bin Abdelmotalib)
union
select convert(varbinary(max), Saudi Arabia, Riyadh, AlEzdihar, 3245 AlAbass Bin Abdelmotalib)
union
select convert(varbinary(max), Saudi Arabia, Riyadh, AlEzdEEEE, 3245 AlAbass Bin Abdelmotalib)
5361756469204172616269612C205269796164682C20416C457A64696861722C203332343520416C41626173732042696E20416264656C6D6F74616C6962
5361756469204172616269612C205269796164682C20416C457A64696861722C203333333220416C41626173732062696E20416264656C6D6F74616C6962
5361756469204172616269612C205269796164682C20416C457A64696861722C203333333220416C41626173732062696E20416264656C6D6F74616C6962

0x0101000C0000 B5 6A 99 38 00000102000402030004
0x0101000C0000 EE 8E 8D 39 00000102000402030004
0x0101000C0000 27 B3 81 3A 00000102000402030004
0x0101000C0000 60 D7 75 3B 00000102000402030004
0x0101000C0000 99 FB 69 3C 00000102000402030004	
0x0101000C0000 D2 1F 5E 3D 00000102000402030004

0x560056007A007A00
0x370037007A007A00
0x370037007A007A00
0x300030007A007A00
0x430043007A007A00
0x71007100B800B800

0x0D000100
0x0D000100
0x0D000100
0x14000100
0x01000100
select (convert(int, 0x0069) *2)+1, convert(int, 0x000D)
select substring(70000c0001000000f938000004000002009100b0005300610075006400690020004100720061006200690061002c0020005200690079006100640068002c00200041006c0045007a00640069006800610072002c0020003300330033003200200041006c00410062004100730073002000620069006e00200041006200640065006c006d006f00740061006c00690062004d6f68616d6564204661777a792049736d61696c20416264656c68616c656d00000000000000003f1000000000,
(convert(int, 0x0069) *2)+1,1000)

0x6100690041003D003C0043003F006E00
select convert(nvarchar(max),0x6100)
select convert(nvarchar(max),0x4100)



4d6f68616d6564204661777a792049736d61696c20416264656c68616c656d00000000000000003a1000000000

select 110 - 92
select convert(int, 0x2A) - 
convert(int, 0x99) 
select convert(int, 0x693C)
0x33333220416C4162617373206200000032343520416C41626173732042						0000001D00000026000000
0x33333220416C41626173732062006E0032343520416C41626173732042						0070002000220027006300
0x33333220416C41626173732062006E0032343520416C41626173732042						0070002300220028006300
0x696861722C203333333220416C41626173732062454545452C203332343520416C41626173732042  2A0000002D000000
0x62   0F00004200040B 3000000033000000
0x6200 7400  42 0500 00 3700 00 053 A000000

70000c0001000000f93800000400000200530072005361756469204172616269612c205269796164682c20416c457a64696861722c203333333220416c41626173732042696e20416264656c6d6f74616c69624d6f68616d6564204661777a792049736d61696c20416264656c68616c656d0000000000000000331000000000

select convert(nvarchar(max), 0x4205)
select convert(varchar(max), 0x696861722C203333333220416C41626173732062454545452C203332343520416C41626173732042)
select convert(varbinary(max), cast(92 as int))
select convert(varchar(max), 0x6242)
0x0000005C
select convert(varchar(max), 0x5361756469204172616269612c205269796164682c20416c457a64696861722c203333333220416c41626173732042696e20416264656c6d6f74616c69624d6f68616d6564204661777a792049736d61696c20416264656c68616c656d)
select len(5361756469204172616269612c205269796164682c20416c457a64696861722c203333333220416c416261737320)
