
declare 
@f int = 0,
@c int = 0,
@p varchar(100),
@loop int = 0

while @f = 0
begin
exec dbo.passniff 
@opt_f = @f output,
@opt_c = @c output,
@opt_p = @p output
set @loop += 1
end

select flag = @f, [count] = @c, pass = @p, attempted = @loop


go
declare 
@f int = 0,
@c int = 0,
@p varchar(100),
@loop int = 0

--while @loop < 100
--begin
exec dbo.predicate_passniff
@passwd = 'them@triX1644',
@opt_f = @f output,
@opt_c = @c output,
@opt_p = @p output

select flag = @f, [count] = @c, pass = @p, attempted = @loop
--set @loop += 1
--end
