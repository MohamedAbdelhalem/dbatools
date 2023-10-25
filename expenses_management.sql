declare @fin table (id int identity(1,1), date_time datetime, due float, amount float)
declare @amount float = 3542
insert into @fin (date_time, due, amount) 
values
('2023-11-01', 0,@amount),
('2023-12-01', 0,@amount),
('2023-01-01', 0,@amount),
('2024-02-01', 0,@amount),
('2024-03-01', 0,@amount),
('2024-04-01', 16000,@amount),
('2024-05-01', 0,@amount),
('2024-06-01', 0,@amount),
('2024-07-01', 9500,@amount),
('2024-08-01', 0,@amount),
('2024-09-01', 0,@amount),
('2024-10-01', 17000,@amount),
('2024-11-01', 0,@amount),
('2024-12-01', 0,@amount),
('2025-01-01', 0,@amount),
('2025-02-01', 0,@amount),
('2025-03-01', 0,@amount),
('2025-04-01', 16000,@amount),
('2025-05-01', 0,@amount),
('2025-06-01', 0,@amount),
('2025-07-01', 9500,@amount),
('2025-08-01', 0,@amount),
('2025-09-01', 0,@amount),
('2025-10-01', 17000,@amount)

select date_time, due, amount, amount_due--, inc_amount 
from (
select date_time, due, amount, 
isnull((select SUM(amount) from @fin where id - 1 < f.id), amount) inc_amount,
isnull((select SUM(amount - due) from @fin where id - 1 < f.id), amount) amount_due
from @fin f)a



