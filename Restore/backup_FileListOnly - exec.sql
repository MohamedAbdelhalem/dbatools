exec dbo.backup_FileListOnly
@backupfile			= N'\\npci2.d2fs.albilad.com\DBTEMP\T24DBXTREMIOT3\T24_support\FULL\T24DBXTREMIOT3_T24_support_FULL_20230319_012100.bak',
@db_name			= 'T24SDC8',
@file_id			= 1,
@recovery			= 1,
@with_replace		= 1,
@show_size_require	= 1,
@option				= 1,
--@option 1 = database already exist and you will restore with the same locations
--@option 2 = use the pathes that you have on table restore_location_groups
--@option 3 = use the same location of the backup file - use this one for availability databases 
--@option 4 = manually change the location by using replace function 
@action				= 1
--@action 1 = print
--@action 2 = restore
--@action 3 = print + restore