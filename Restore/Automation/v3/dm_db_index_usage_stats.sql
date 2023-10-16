select object_name(object_id),* from sys.dm_db_index_usage_stats
where object_id in (object_id('MAIL_OUT'),object_id('MAIL_ARCHIVE'))

