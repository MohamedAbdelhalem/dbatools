declare @fin table (id int identity(1,1), date_time datetime, due float, due_desc nvarchar(100), amount float)
declare 
@start	float = 3500,
@amount float,
@number float = -1

set @amount = @start

while @number < 0
begin

delete @fin 

insert into @fin (date_time, due, due_desc, amount) 
values
('2024-10-01', 0,N'',@amount),
('2024-11-01', 0,N'',@amount),
('2024-12-01', 0,N'',@amount),
('2025-01-01', 0,N'',@amount),
('2025-02-01', 0,N'',@amount),
('2025-03-01', 19500,N'ايجار قسظ ثاني',@amount),
('2025-04-01', 0,N'',@amount),
('2025-05-01', 0,N'',@amount),
('2025-06-01', 0,N'',@amount),
('2025-07-01', 9500,N'ضريبة التابعين',@amount),
('2025-08-01', 0,N'',@amount),
('2025-09-01', 19500,N'ايجار قسظ أول',@amount),
('2025-10-01', 0,N'',@amount),
('2025-11-01', 0,N'',@amount),
('2025-12-01', 0,N'',@amount),
('2026-01-01', 0,N'',@amount),
('2026-02-01', 0,N'',@amount),
('2026-03-01', 19500,N'ايجار قسظ ثاني',@amount),
('2026-04-01', 0,N'',@amount),
('2026-05-01', 0,N'',@amount),
('2026-06-01', 0,N'',@amount),
('2026-07-01', 9500,N'ضريبة التابعين',@amount),
('2026-08-01', 0,N'',@amount),
('2026-09-01', 19500,N'ايجار قسظ أول',@amount),
('2026-10-01', 0,N'',@amount)

select @number = min(amount_due) 
from (
select date_time, due, amount, 
isnull((select SUM(amount) from @fin where id - 1 < f.id), amount) inc_amount,
isnull((select SUM(amount - due) from @fin where id - 1 < f.id), amount) amount_due
from @fin f)a

set @amount = @amount + 1
end

select 
convert(date,date_time,120) due_date, 
master.dbo.format(due,-1) due_amount, 
due_desc,
master.dbo.format(amount,-1) monthly_saving_amount, 
master.dbo.format(amount_due,-1) incremental_monthly_saving,
case 
when amount_due = min(amount_due) over() then 'Smallest Amount is '+master.dbo.format(min(amount_due) over(),-1) 
when amount_due = max(amount_due) over() then 'Biggest Amount is '+master.dbo.format(max(amount_due) over(),-1) 
else '' end [statistics]
from (
select date_time, due, amount, due_desc,
isnull((select SUM(amount) from @fin where id - 1 < f.id), amount) inc_amount,
isnull((select SUM(amount - due) from @fin where id - 1 < f.id), amount) amount_due
from @fin f)a
order by due_date

