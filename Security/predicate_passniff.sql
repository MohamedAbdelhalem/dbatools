USE [master]
GO
/****** Object:  StoredProcedure [dbo].[predicate_passniff]    Script Date: 11/21/2023 9:26:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[predicate_passniff] (
@passwd varchar(20),
@opt_f int output,
@opt_c int output,
@opt_p varchar(50) output
)
as
begin
--declare @loop int = 0

--while @loop = 0
--begin

--SELECT name FROM sys.sql_logins   
--WHERE PWDCOMPARE('123', password_hash) = 1 ;  

declare @table_all table (letter varchar(100) collate SQL_Latin1_General_CP1_CS_AS)
declare @table_001 table (id int identity(1,1), letter varchar(100) collate SQL_Latin1_General_CP1_CS_AS)
declare @table_002 table (letter varchar(100) collate SQL_Latin1_General_CP1_CS_AS)
declare @table_003 table (letter varchar(100) collate SQL_Latin1_General_CP1_CS_AS)
set nocount on

insert into @table_all (letter) values 
('0'),
('1'),
('2'),
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9'),
('A'),
('a'),
('B'),
('b'),
('C'),
('c'),
('D'),
('d'),
('E'),
('e'),
('F'),
('f'),
('G'),
('g'),
('H'),
('h'),
('I'),
('i'),
('J'),
('j'),
('K'),
('k'),
('L'),
('l'),
('M'),
('m'),
('N'),
('n'),
('o'),
('O'),
('P'),
('p'),
('Q'),
('q'),
('R'),
('r'),
('S'),
('s'),
('T'),
('t'),
('U'),
('u'),
('V'),
('v'),
('W'),
('w'),
('X'),
('x'),
('Y'),
('y'),
('Z'),
('z'),
('!'),
('@'),
('#'),
('$'),
('%'),
('^'),
('&'),
('*'),
('('),
(')'),
('_'),
('-'),
('='),
('+'),
('\'),
('/'),
('|'),
('"'),
(':'),
(';'),
('.'),
(','),
('`'),
('?')

insert into @table_001 (letter)
select top 10 * from @table_all where letter like '[0-9]' order by CRYPT_GEN_RANDOM(20)

insert into @table_001 (letter) 
select top 23 letter from @table_all where letter like '[A-z]' order by CRYPT_GEN_RANDOM(1)

insert into @table_001 (letter)
select top 20 letter from @table_all where letter not like '[A-z]' and letter not like '[0-9]' order by CRYPT_GEN_RANDOM(1)

--select count(*) from @table_001

declare
@count tinyint,
@pass char(13),
@l1 char(1),@l2 char(1),@l3 char(1),@l4 char(1),@l5 char(1),@l6 char(1),@l7 char(1),@l8 char(1),@l9 char(1),@l10 char(1),@l11 char(1),@l12 char(1),@l13 char(1)

select @l1  = letter from @table_001 where id = 1 order by CRYPT_GEN_RANDOM(1)
select @l2  = letter from @table_001 where id = 2 order by CRYPT_GEN_RANDOM(2)
select @l3  = letter from @table_001 where id = 3 order by CRYPT_GEN_RANDOM(3)
select @l4  = letter from @table_001 where id = 4 order by CRYPT_GEN_RANDOM(4)
select @l5  = letter from @table_001 where id = 5 order by CRYPT_GEN_RANDOM(5)
select @l6  = letter from @table_001 where id = 6 order by CRYPT_GEN_RANDOM(6)
select @l7  = letter from @table_001 where id = 7 order by CRYPT_GEN_RANDOM(7)
select @l8  = letter from @table_001 where id = 8 order by CRYPT_GEN_RANDOM(8)
select @l9  = letter from @table_001 where id = 9 order by CRYPT_GEN_RANDOM(9)
select @l10 = letter from @table_001 where id = 10 order by CRYPT_GEN_RANDOM(10)
select @l11 = letter from @table_001 where id = 11 order by CRYPT_GEN_RANDOM(11)
select @l12 = letter from @table_001 where id = 12 order by CRYPT_GEN_RANDOM(12)
select @l13 = letter from @table_001 where id = 13 order by CRYPT_GEN_RANDOM(13)


select *
from (
select top 1
  l01.letter 
+ l02.letter 
+ l03.letter 
+ l04.letter 
+ l05.letter 
+ l06.letter 
+ l07.letter 
+ l08.letter 
+ l09.letter 
+ l10.letter 
+ l11.letter 
+ l12.letter 
+ l13.letter
pass

from		@table_001 l01 
cross apply @table_001 l02 
cross apply @table_001 l03 
cross apply @table_001 l04 
cross apply @table_001 l05 
cross apply @table_001 l06 
cross apply @table_001 l07 
cross apply @table_001 l08 
cross apply @table_001 l09 
cross apply @table_001 l10 
cross apply @table_001 l11 
cross apply @table_001 l12 
cross apply @table_001 l13 
order by CRYPT_GEN_RANDOM(13)
)x
--where pass = @passwd

select @pass = isnull(@l1,char(1))+isnull(@l2,char(1))+isnull(@l3,char(1))+isnull(@l4,char(1))+isnull(@l5,char(1))+isnull(@l6,char(1))+isnull(@l7,char(1))+isnull(@l8,char(1))+isnull(@l9,char(1))+isnull(@l10,char(1))+isnull(@l11,char(1))+isnull(@l12,char(1))+isnull(@l13,char(1))
select @count = IIF(@l1 is NULL,0,1)+IIF(@l2 is NULL,0,1)+IIF(@l3 is NULL,0,1)+IIF(@l4 is NULL,0,1)+IIF(@l5 is NULL,0,1)+IIF(@l6 is NULL,0,1)+IIF(@l7 is NULL,0,1)+IIF(@l8 is NULL,0,1)+IIF(@l9 is NULL,0,1)+IIF(@l10 is NULL,0,1)+IIF(@l11 is NULL,0,1)+IIF(@l12 is NULL,0,1)+IIF(@l13 is NULL,0,1)

set @opt_f = case when @pass = @passwd then 1 else 0 end
set @opt_c = @count
set @opt_p = @pass
--select @pass, @count, case when @count = 12 then 1 else 0 end

set nocount off


--select *
--from (
--select 
--  l01.letter 
--+ l02.letter 
--+ l03.letter 
--+ l04.letter 
--+ l05.letter 
--+ l06.letter 
--+ l07.letter 
--+ l08.letter 
--+ l09.letter 
--+ l10.letter 
--+ l11.letter 
--+ l12.letter 
----+ l13.letter
--pass

--from		@table_001 l01 
--cross apply @table_001 l02 
--cross apply @table_001 l03 
--cross apply @table_001 l04 
--cross apply @table_001 l05 
--cross apply @table_001 l06 
--cross apply @table_001 l07 
--cross apply @table_001 l08 
--cross apply @table_001 l09 
--cross apply @table_001 l10 
--cross apply @table_001 l11 
--cross apply @table_001 l12 
----cross apply @table_001 l13 
--)x
--where pass = 'P@$$w0rd@123'
end

