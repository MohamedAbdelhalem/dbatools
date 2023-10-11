exec [dbo].[sp_shrink_file]
@file_type				= 'data', --values (data or log).
@file_id				= 0, -- values (0 = all or file id (1,2,3,4,5,6,...)).
@start_from				= 9,
@except_files			= '10,11,12,13,14,16,17,19,20',
@file_percent			= 2, -- value = this is the percent number that you want to shrink with with batches like every 5 seconds it will get this value to shrink the file.
@file_used_buffer_mb	= 2048 -- value = @file_used_buffer_mb MB additional space added on the total used space of the file.
