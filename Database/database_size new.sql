Exec [master].[dbo].[database_size]
@databases		= '*',
@with_system	= 1,
@threshold_pct	= 85,
@volumes		= '*',
@where_size_gt  = 0,
@datafile		= '*',
@report			= 1,
@over_threshold = 0
