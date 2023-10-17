--to recursive folders

declare 
@disk varchar(10) = 'N', 
@show int = 3 --1 show files, 2 show count, 3 delete files
declare @table table (output_text varchar(max))
declare @sql varchar(1000)
set @sql = 'xp_cmdshell ''PowerShell.exe -Command "& {Get-ChildItem -Path '+@disk+':\ -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName}"'''
insert into @table
exec(@sql)

if @show = 1
begin
select output_text
from @table
where output_text like @disk+':\$RECYCLE.BIN\%'
end
else
if @show = 2
begin
select master.dbo.format(count(*),-1) [$RECYCLE.BIN file]
from @table
where output_text like @disk+':\$RECYCLE.BIN\%'
end
else 
if @show = 3
begin
--cmd
--to clean the recycle bin

--rd /s /q E:\$Recycle.bin
set @sql = 'xp_cmdshell ''rd /s /q '+@disk+':\$Recycle.bin'''
print(@sql)
exec(@sql)
end

