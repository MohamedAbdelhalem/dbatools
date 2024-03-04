use [database name]
go
declare 
@file_type varchar(50) = 'data', --values (data or log).
--@file_id varchar(max) = '1,3,5,7,8,9,13,16,17', -- values (0 = all or file id (1,2,3,4,5,6,...)).
@file_id varchar(max) = '1,3,4,5,6,9,16', -- values (0 = all or file id (1,2,3,4,5,6,...)).
@start_from int = 0,
@except_files varchar(100) = '9',
@shrink_size_type int = 3, 
--1 percentage %
--2 fixed size mb
--3 mix between the 2 types
	--first it uses fixed size until it reched the mix_threshold then it use the percentage number %
@mix_threshold_mb float = 2048,
@file_percent float = 1, -- value = this is the percent number that you want to shrink with batches like every 5 seconds it will get this value to shrink the file.
@shrink_fixed_size_mb float = 1024,
@file_used_buffer_mb int = 512 -- value = @file_used_buffer_mb MB additional space added on the total used space of the file.

declare @file_size bigint, @file_dbcc bigint, @file_used bigint, @file_name nvarchar(300), @message nvarchar(1000)
declare cursor_files cursor fast_forward
for
select --FILE_ID, --((cast(size as bigint) * 8) / 1024) , (@shrink_fixed_size_mb) ,
[file_size] = ((cast(size as bigint) * 8) / 1024), 
[file_dbcc] = case 
			  when @shrink_size_type = 1 then cast(((cast(size as bigint) * 8) / 1024) - ((cast(size as bigint) * 8 / 1024.0) / 100 * @file_percent) as bigint)
			  when @shrink_size_type in (2,3) then cast((((cast(size as bigint) * 8) / 1024) - (@shrink_fixed_size_mb)) as bigint)
			  end, 
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
		isnull(','+[36],'')+isnull(','+[37],'')+isnull(','+[38],'')+isnull(','+[39],'')+isnull(','+[40],'')+
		isnull(','+[46],'')+isnull(','+[47],'')+isnull(','+[48],'')+isnull(','+[49],'')+isnull(','+[50],'')+
		isnull(','+[51],'')+isnull(','+[52],'')+isnull(','+[53],'')+isnull(','+[54],'')+isnull(','+[55],'')+
		isnull(','+[56],'')+isnull(','+[57],'')+isnull(','+[58],'')+isnull(','+[59],'')+isnull(','+[60],'')+
		isnull(','+[61],'')+isnull(','+[62],'')+isnull(','+[63],'')+isnull(','+[64],'')+isnull(','+[65],'')+
		isnull(','+[66],'')+isnull(','+[67],'')+isnull(','+[68],'')+isnull(','+[69],'')+isnull(','+[70],'')+
		isnull(','+[71],'')+isnull(','+[72],'')+isnull(','+[73],'')+isnull(','+[74],'')+isnull(','+[75],'')+
		isnull(','+[76],'')+isnull(','+[77],'')+isnull(','+[78],'')+isnull(','+[79],'')+isnull(','+[80],'')+
		isnull(','+[81],'')+isnull(','+[82],'')+isnull(','+[83],'')+isnull(','+[84],'')+isnull(','+[85],'')+
		isnull(','+[86],'')+isnull(','+[87],'')+isnull(','+[88],'')+isnull(','+[89],'')+isnull(','+[90],'')+
		isnull(','+[91],'')+isnull(','+[92],'')+isnull(','+[93],'')+isnull(','+[94],'')+isnull(','+[95],'')+
		isnull(','+[96],'')+isnull(','+[97],'')+isnull(','+[98],'')+isnull(','+[99],'')+isnull(','+[100],'')+
		isnull(','+[101],'')+isnull(','+[102],'')+isnull(','+[103],'')+isnull(','+[104],'')+isnull(','+[105],'')+
		isnull(','+[106],'')+isnull(','+[107],'')+isnull(','+[108],'')+isnull(','+[109],'')+isnull(','+[110],'')
from (
select row_number() over(order by file_id) id, cast(file_id as varchar(10)) [file_id]
from sys.master_files 
where database_id = db_id() 
and type = case @file_type when 'data' then 0 else 1 end 
and (file_id > case 
				when case 
						when charindex(',',@file_id) = 0 then cast(@file_id as int) 
						else 999999 
					 end != 0 then null else 0 end
	 or file_id in (select cast(ltrim(rtrim(value)) as int) file_id from master.dbo.Separator(@file_id,','))))a
pivot					-- and lines here too if you need more files.
(max(file_id) for id in ([01],[02],[03],[04],[05],[06],[07],[08],[09],[10],
						 [11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
						 [21],[22],[23],[24],[25],[26],[27],[28],[29],[30],
						 [31],[32],[33],[34],[35],[36],[37],[38],[39],[40],
						 [41],[42],[43],[44],[45],[46],[47],[48],[49],[50],
						 [51],[52],[53],[54],[55],[56],[57],[58],[59],[60],
						 [61],[62],[63],[64],[65],[66],[67],[68],[69],[70],
						 [71],[72],[73],[74],[75],[76],[77],[78],[79],[80],
						 [81],[82],[83],[84],[85],[86],[87],[88],[89],[90],
						 [91],[92],[93],[94],[95],[96],[97],[98],[99],[100],
						 [101],[102],[103],[104],[105],[106],[107],[108],[109],[110]))p), ',') 
) or file_id = case 
						when charindex(',',@file_id) = 0 then cast(@file_id as int) 
						else 999999 
					 end)
order by file_id

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
		@file_dbcc = case when @shrink_size_type = 1 then cast(((cast(size as bigint) * 8) / 1024) - ((cast(size as bigint) * 8 / 1024.0) / 100 * @file_percent) as bigint)
						  when @shrink_size_type = 2 then cast((((cast(size as bigint) * 8) / 1024) - (@shrink_fixed_size_mb)) as bigint)
						  when @shrink_size_type = 3 then case when @file_dbcc < (@file_used + @mix_threshold_mb) 
																then cast(((cast(size as bigint) * 8) / 1024) - ((cast(size as bigint) * 8 / 1024.0) / 100 * @file_percent) as bigint)
																else cast((((cast(size as bigint) * 8) / 1024) - (@shrink_fixed_size_mb)) as bigint)
					end
					end, 
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

