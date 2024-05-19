declare @source_folders varchar(max) = 'C:\source_doc_01, C:\source_doc_02, C:\source_doc_03'
declare @table table (output_text varchar(max), source_path varchar(500))
declare 
@xp_cmdshell	varchar(2000), 
@sql_insert		varchar(max),
@path			varchar(1500),
@name			varchar(1500),
@file_name		varchar(2500)
declare cursor_path cursor fast_forward
for
select ltrim(rtrim(value))
from master.dbo.separator(@source_folders, ',')
order by id

open cursor_path
fetch next from cursor_path into @path
while @@fetch_status = 0
begin

set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@path+'"'''

insert into @table (output_text)
exec(@xp_cmdshell)

update @table set source_path = @path where source_path is null

fetch next from cursor_path into @path
end
close cursor_path
deallocate cursor_path

declare cursor_import_as_filetable cursor fast_forward
for
select ltrim(rtrim(substring(output_text, charindex(' ', output_text), len(output_text)))) [name], source_path+'\'+ltrim(rtrim(substring(output_text, charindex(' ', output_text), len(output_text)))) [file_name]
from (
select ltrim(rtrim(substring(output_text, charindex(' ', output_text), len(output_text)))) output_text, source_path
from (
select ltrim(rtrim(substring(output_text, charindex(' ', output_text), len(output_text)))) output_text, source_path
from @table
where output_text not like '%<DIR>%'
--and output_text like '%M %'
and output_text like '%:%'
and output_text not like '%Directory of %')a)b

open cursor_import_as_filetable
fetch next from cursor_import_as_filetable into @name, @file_name
while @@fetch_status = 0
begin

set @sql_insert = 'insert into [AdventureWorks2019].[dbo].[Documents] ([name],[file_stream])
select '+''''+@name+''''+', * FROM OPENROWSET(BULK N'+''''+@file_name+''''+', SINGLE_BLOB) AS FileData'
exec(@sql_insert)

fetch next from cursor_import_as_filetable into @name, @file_name
end
close cursor_import_as_filetable
deallocate cursor_import_as_filetable

