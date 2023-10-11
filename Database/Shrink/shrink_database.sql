use EInvoice_PRD
go
declare 
@file_type varchar(50) = 'data', --values (data or log).
@file_id int = 1, -- values (0 = all or file id (1,2,3,4,5,6,...)).
@start_from int = 0,
@except_files varchar(100) = '0',
@file_percent float = 0.1, -- value = this is the percent number that you want to shrink with batches like every 5 seconds it will get this value to shrink the file.
@file_used_buffer_mb int = 512 -- value = @file_used_buffer_mb MB additional space added on the total used space of the file.

--select file_id, name, physical_name from sys.master_files where database_id > 4
declare @file_size bigint, @file_dbcc bigint, @file_used bigint, @file_name nvarchar(300), @message nvarchar(1000)
declare cursor_files cursor fast_forward
for
select 
[file_size] = ((cast(size as bigint) * 8) / 1024), 
[file_dbcc] = cast(((cast(size as bigint) * 8) / 1024) - ((cast(size as bigint) * 8 / 1024.0) / 100 * @file_percent) as bigint), 
[file_used] = cast((cast(FILEPROPERTY(name, 'spaceused') as bigint) * 8.0) / 1024 as bigint) + @file_used_buffer_mb, 
[file_name] = name
from sys.master_files
where database_id = db_id()
and file_id >= @start_from
and file_id not in (select cast(ltrim(rtrim(value)) as int) from master.dbo.Separator(@except_files,','))
and type = case @file_type when 'data' then 0 else 1 end
and (file_id in (
select cast(value as int)
from master.dbo.separator(( -- now it will get only 40 files, if you need to use more just add another lines till what you want.
select	isnull(    [01],'')+isnull(','+[02],'')+isnull(','+[03],'')+isnull(','+[04],'')+isnull(','+[05],'')+
		isnull(','+[06],'')+isnull(','+[07],'')+isnull(','+[08],'')+isnull(','+[09],'')+isnull(','+[10],'')+
		isnull(','+[11],'')+isnull(','+[12],'')+isnull(','+[13],'')+isnull(','+[14],'')+isnull(','+[15],'')+
		isnull(','+[16],'')+isnull(','+[17],'')+isnull(','+[18],'')+isnull(','+[19],'')+isnull(','+[20],'')+
		isnull(','+[21],'')+isnull(','+[22],'')+isnull(','+[23],'')+isnull(','+[24],'')+isnull(','+[25],'')+
		isnull(','+[26],'')+isnull(','+[27],'')+isnull(','+[28],'')+isnull(','+[29],'')+isnull(','+[30],'')+
		isnull(','+[31],'')+isnull(','+[32],'')+isnull(','+[33],'')+isnull(','+[34],'')+isnull(','+[35],'')+
		isnull(','+[36],'')+isnull(','+[37],'')+isnull(','+[38],'')+isnull(','+[39],'')+isnull(','+[40],'')
from (
select row_number() over(order by file_id) id, cast(file_id as varchar(10)) [file_id]
from sys.master_files 
where database_id = db_id() 
and type = case @file_type when 'data' then 0 else 1 end and file_id > case when @file_id != 0 then null else 0 end)a
pivot					-- and lines here too if you need more files.
(max(file_id) for id in ([01],[02],[03],[04],[05],[06],[07],[08],[09],[10],
						 [11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
						 [21],[22],[23],[24],[25],[26],[27],[28],[29],[30],
						 [31],[32],[33],[34],[35],[36],[37],[38],[39],[40]))p), ',') 
) or file_id = @file_id)

open cursor_files
fetch next from cursor_files into @file_size, @file_dbcc, @file_used, @file_name
while @@FETCH_STATUS = 0
begin
	select master.dbo.numbersize(@file_used,'mb') file_used, master.dbo.numbersize(@file_dbcc,'mb') file_dbcc
	while @file_used < @file_dbcc
	begin
		Print('DBCC SHRINKFILE ('+@file_name+' , '+master.dbo.NumberSize(@file_dbcc,'MB')+') = DbccSpaceReclaim '+master.dbo.numbersize(@file_size - @file_dbcc,'mb'))
		DBCC SHRINKFILE (@file_name , @file_dbcc)

		set @message = @file_type+' file "'+@file_name+'" has been shrank!, it was '+master.dbo.numbersize(@file_size,'mb')+' and now is '+master.dbo.numbersize(@file_dbcc,'mb')+' at '+convert(varchar(30), getdate(), 120)
		RAISERROR(@message, 1, 1) WITH NOWAIT;

		select 
		@file_size = ((cast(size as bigint) * 8) / 1024), 
		@file_dbcc = ((cast(size as bigint) * 8) / 1024) - ((cast(size as bigint) * 8 / 1024.0) / 100 * @file_percent), 
		@file_used = cast((cast(FILEPROPERTY(name, 'spaceused') as bigint) * 8.0) / 1024 as bigint) + @file_used_buffer_mb, 
		@file_name = name
		from sys.master_files
		where database_id = db_id()
		and name = @file_name

		waitfor delay '00:00:05'
	end
fetch next from cursor_files into @file_size, @file_dbcc, @file_used, @file_name
end
close cursor_files
deallocate cursor_files

go