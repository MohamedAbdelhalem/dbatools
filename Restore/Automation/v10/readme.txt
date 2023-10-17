In this version, you can able to restore only transaction log backups along with the specified full backup;

like you need to restore till 2023-10-16 00:01:00 a.m. and you don't want to use the daily differential backups
but just the full backup of 2023-10-06 12:00:00 p.m. 
e.g. your backup plan is:

* Weekly full backup.
* Daily differential backup.
* Every 10 minutes Transaction log backup.
