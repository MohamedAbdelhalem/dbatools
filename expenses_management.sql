declare @fin table (id int identity(1,1), date_time datetime, due float, amount float)
declare 
@start	float = 3500,
@amount float,
@number float = -1

set @amount = @start

while @number < 0
begin

delete @fin 

insert into @fin (date_time, due, amount) 
values
('2024-10-01', 0,@amount),
('2024-11-01', 0,@amount),
('2024-12-01', 0,@amount),
('2025-01-01', 0,@amount),
('2025-02-01', 0,@amount),
('2025-03-01', 19500,@amount),
('2025-04-01', 0,@amount),
('2025-05-01', 0,@amount),
('2025-06-01', 0,@amount),
('2025-07-01', 9500,@amount),
('2025-08-01', 0,@amount),
('2025-09-01', 19500,@amount),
('2025-10-01', 0,@amount),
('2025-11-01', 0,@amount),
('2025-12-01', 0,@amount),
('2026-01-01', 0,@amount),
('2026-02-01', 0,@amount),
('2026-03-01', 19500,@amount),
('2026-04-01', 0,@amount),
('2026-05-01', 0,@amount),
('2026-06-01', 0,@amount),
('2026-07-01', 9500,@amount),
('2026-08-01', 0,@amount),
('2026-09-01', 19500,@amount),
('2026-10-01', 0,@amount)

select top 1 @number = min(amount_due) over() from (
select date_time, due, amount, 
isnull((select SUM(amount) from @fin where id - 1 < f.id), amount) inc_amount,
isnull((select SUM(amount - due) from @fin where id - 1 < f.id), amount) amount_due
from @fin f)a

set @amount = @amount + 1
end

select 
convert(date,date_time,120) due_date, 
master.dbo.format(due,-1) due_amount, 
master.dbo.format(amount,-1) monthly_saving_amount, 
master.dbo.format(amount_due,-1) incremental_monthly_payment,
case 
when amount_due = min(amount_due) over() then 'Smallest Amount is '+master.dbo.format(min(amount_due) over(),-1) 
when amount_due = max(amount_due) over() then 'Biggest Amount is '+master.dbo.format(max(amount_due) over(),-1) 
else '' end [statistics]
from (
select date_time, due, amount, 
isnull((select SUM(amount) from @fin where id - 1 < f.id), amount) inc_amount,
isnull((select SUM(amount - due) from @fin where id - 1 < f.id), amount) amount_due
from @fin f)a
order by due_date

