-- to run this job after 20 second
exec [dbo].[sp_schedule_modifier]
@job_name ='Automatic Restore Job', 
@after = 'S', @amount = 20

-- to run this job at 09 am on 23 of December 2022
exec [dbo].[sp_schedule_modifier]
@job_name ='Automatic Restore Job', 
@modified_date  = '2022-12-23 09:00:00.000'
