CREATE FUNCTION [dbo].[Hex_to_Text] 
(@hex varchar(max))
returns varchar(max)
as
begin
declare @table table (
t varchar(5) Collate SQL_Latin1_General_CP1_CS_AS, 
h varchar(5) Collate SQL_Latin1_General_CP1_CS_AS)
insert into @table values 
('0','30'),('1','31'),('2','32'),('3','33'),('4','34'),('5','35'),('6','36'),('7','37'),('8','38'),('9','39'),
('a','61'),('b','62'),('c','63'),('d','64'),('e','65'),('f','66'),('g','67'),('h','68'),('i','69'),('j','6A'),
('k','6B'),('l','6C'),('m','6D'),('n','6E'),('o','6F'),('p','70'),('q','71'),('r','72'),('s','73'),('t','74'),
('u','75'),('v','76'),('w','77'),('x','78'),('y','79'),('z','7A'),('A','41'),('B','42'),('C','43'),('D','44'),
('E','45'),('F','46'),('G','47'),('H','48'),('I','49'),('J','4A'),('K','4B'),('L','4C'),('M','4D'),('N','4E'),
('O','4F'),('P','50'),('Q','51'),('R','52'),('S','53'),('T','54'),('U','55'),('V','56'),('W','57'),('X','58'),
('Y','59'),('Z','5A'),
(' ','20'),(':','3A'),('-','2D'),('.','2E'),('_','5F'),('+','2B'),('%','25'),
('@','40'),('!','21'),('"','22'),('&','26'),('(','28'),(')','29'),('*','2A'),
('+','2B'),(',','2C'),('.','2E'),('/','2F'),('\','5C'),('[','5B'),(']','5D'),
('#','23'),('$','24'),(':','3A'),(';','3B'),('<','3C'),('>','3E'),('=','3D'),
('?','3F'),('“','93'),('”','94'),('''','27'),('{','7B'),('}','7D'),
(convert(varchar(max),0x0A),'0A'),
('	','09'),
(convert(varchar(max),0x0D),'0D')

declare 
@convert	varchar(5),
@text		varchar(5),
@result		varchar(max),
@loop		int = 0

while @loop < len(@hex)
begin
set @text = ''
select @convert = substring(@hex,@loop+1,2)
select @text = t
from @table
where h = @convert
select @result = isnull(@result,'')+isnull(@text,'')

set @loop = @loop + 2
end
return @result
end
