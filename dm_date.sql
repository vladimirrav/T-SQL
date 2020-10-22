use DW;
set nocount on;
set dateformat ymd;
set language brazilian;

if object_id('dw.dm_data') is not null
begin
	drop table dw.dm_data;
end;

create table dw.dm_data ( 
	sk_data int,
	data date,
	data_ymd varchar(10),
	dia_mes int,
	dia_ano int,
	dia_semana int,
	nome_dia_semana varchar(20),
	semana_mes int,
	semana_ano int,
	mes int,
	nome_mes varchar(20),
	trimestre int,
	nome_trimestre varchar(20),
	ano int,
	primeiro_dia_mes char(1),
	ultimo_dia_mes char(1),
	dia_util char(1),
	fim_de_semana char(1),
	feriado char(1),
	nome_feriado varchar(100),
	constraint [pk_dm_data] primary key clustered 
	(sk_data asc)
	with (
		pad_index = off,
		statistics_norecompute = off,
		ignore_dup_key = off,
		allow_row_locks = on,
		allow_page_locks = on,
		fillfactor = 90
	) on [PRIMARY] 
) on [PRIMARY] 

truncate table dw.dm_data;

declare	@StartDate datetime,
		@EndDate datetime,
		@Date datetime;

select	@StartDate = '2015-01-01',
		@EndDate = concat(year(dateadd(year, 1, current_timestamp)), '-12-31');

select @Date = @StartDate 

print 'dw.dm_data - Load'

while @Date <= @EndDate 
begin 
    insert into dw.dm_data 
    ( 
		sk_data,
		data,
		data_ymd,
		dia_mes,
		dia_semana,
		nome_dia_semana,
		mes,
		nome_mes,
		trimestre,
		nome_trimestre,
		semana_ano,
		ano,
		dia_util,
		fim_de_semana,
		feriado,
		nome_feriado
    ) 
	select
		convert(int, convert(varchar, @DATE, 112)) as sk_data,
		convert(date, @Date) data,
		convert(varchar, @Date, 103) data_ymd,
		datepart(day,@DATE) dia_mes,
		datepart(weekday, @DATE) as dia_semana,
		datename(weekday, @DATE) as nome_dia_semana,
		datepart(month,@DATE) mes,
		datename(month,@DATE) nome_mes,
		datepart(quarter, @DATE) trimestre_QQ,
		concat('TR-', format(datepart(quarter, @DATE), replicate('0', 2))) as nome_trimestre,
		datepart(week, @Date) as semana_ano,
		datepart(year,@Date) as ano,
		iif(datepart(weekday, @Date) not in (1, 7), 'S', 'N') as dia_util,
		iif(datepart(weekday, @Date) in (1, 7), 'S', 'N') as fim_de_semana,
		/* Feriados fixos */
		case
			when
				   right(convert(int, convert(varchar, @Date, 112)), 4) = '0101'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '0421'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '0501'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '0907'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '1012'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '1102'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '1115'
				or right(convert(int, convert(varchar, @Date, 112)), 4) = '1225' then 'S'
			else 'N'
		end as feriado,
		case
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '0101' then 'Confraternização universal'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '0421' then 'Tiradentes'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '0501' then 'Dia do trabalhador'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '0907' then 'Independência'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '1012' then 'Nossa Senhora Aparecida'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '1102' then 'Finados'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '1115' then 'Proclamação da república'
			when right(convert(int, convert(varchar, @Date, 112)), 4) = '1225' then 'Natal'
		end as nome_feriado

    select @Date = dateadd(Day, 1, @Date)
end 

print 'Feriados móveis'

;with n as (
	select
		sk_data,
		row_number() over (partition by ano order by sk_data) as dia_ano_n,
		row_number() over (partition by ano, mes order by sk_data) as primeiro_dia_mes_n,
		row_number() over (partition by ano, mes order by sk_data desc) as ultimo_dia_mes_n,
		dia_semana,
		nome_dia_semana
	from dw.dm_data
)
update dt
set
	dia_ano = n.dia_ano_n,
	primeiro_dia_mes = iif(n.primeiro_dia_mes_n = 1, 'S', 'N'),
	ultimo_dia_mes = iif(n.ultimo_dia_mes_n = 1, 'S', 'N')
from dw.dm_data as dt
inner join n on dt.sk_data = n.sk_data

if object_id('tempdb..#feriado_movel') is not null
	drop table #feriado_movel

create table #feriado_movel
(
	sk_data int,
	nome_feriado varchar(100)
)

declare @Year as int = (select min(ano) from dw.dm_data)
while (@Year <= (select max(ano) from dw.dm_data))
begin
	declare
		@EpactCalc int,
		@PaschalDaysCalc int,
		@NumOfDaysToSunday int,
		@EasterMonth int,
		@EasterDay int,
		@sk_data int

	set @EpactCalc = (24 + 19 * (@Year % 19)) % 30
	set @PaschalDaysCalc = @EpactCalc - (@EpactCalc / 28)
	set @NumOfDaysToSunday = @PaschalDaysCalc - ((@Year + @Year / 4 + @PaschalDaysCalc - 13) % 7)

	set @EasterMonth = 3 + (@NumOfDaysToSunday + 40) / 44

	set @EasterDay = @NumOfDaysToSunday + 28 - (31 * (@EasterMonth / 4))
	
	set @sk_data = convert(int, convert(varchar, dateadd(day, -47, convert(date, concat(format(@Year, replicate('0', 4)), format(@EasterMonth, replicate('0', 2)), format(@EasterDay, replicate('0', 2))))), 112))
	insert into #feriado_movel (sk_data, nome_feriado) values (@sk_data, 'Carnaval')

	set @sk_data = convert(int, convert(varchar, dateadd(day, -46, convert(date, concat(format(@Year, replicate('0', 4)), format(@EasterMonth, replicate('0', 2)), format(@EasterDay, replicate('0', 2))))), 112))
	insert into #feriado_movel (sk_data, nome_feriado) values (@sk_data, 'Quarta-feira de cinzas')

	set @sk_data = convert(int, convert(varchar, dateadd(day, -2, convert(date, concat(format(@Year, replicate('0', 4)), format(@EasterMonth, replicate('0', 2)), format(@EasterDay, replicate('0', 2))))), 112))
	insert into #feriado_movel (sk_data, nome_feriado) values (@sk_data, 'Sexta-feira da paixão')
	
	set @sk_data = convert(int, convert(varchar, dateadd(day, 0, convert(date, concat(format(@Year, replicate('0', 4)), format(@EasterMonth, replicate('0', 2)), format(@EasterDay, replicate('0', 2))))), 112))
	insert into #feriado_movel (sk_data, nome_feriado) values (@sk_data, 'Páscoa')
	
	set @sk_data = convert(int, convert(varchar, dateadd(day, 60, convert(date, concat(format(@Year, replicate('0', 4)), format(@EasterMonth, replicate('0', 2)), format(@EasterDay, replicate('0', 2))))), 112))
	insert into #feriado_movel (sk_data, nome_feriado) values (@sk_data, 'Corpus Christi')

	print concat(char(9), 'Carnaval: ', dateadd(day, -47, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay))), ' (', datename(weekday, dateadd(day, -47, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay)))), ')')
	print concat(char(9), 'Quarta-feira de cinzas: ', dateadd(day, -46, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay))), ' (', datename(weekday, dateadd(day, -46, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay)))), ')')
	print concat(char(9), 'Sexta-feira da paixão: ', dateadd(day, -2, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay))), ' (', datename(weekday, dateadd(day, -2, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay)))), ')')
	print concat(char(9), 'Páscoa: ', convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay)), ' (', datename(weekday, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay))), ')')
	print concat(char(9), 'Corpus Christi: ', dateadd(day, 60, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay))), ' (', datename(weekday, dateadd(day, 60, convert(date, concat(@Year, '/', @EasterMonth, '/', @EasterDay)))), ')')
	print concat(char(9), replicate('-', 50))
	set @Year += 1
end;

print 'Dia útil, feriado'

update d
set nome_feriado = fm.nome_feriado,
	feriado = 1,
	dia_util = 0
from dw.dm_data as d
cross apply (
		select f.nome_feriado
		from #feriado_movel as f
		where f.sk_data = d.sk_data
	) as fm

print 'Semana do mês'

;with semana_mes as (
	select
		ano,
		mes,
		semana_ano,
		row_number () over (partition by ano, mes order by ano, mes) as semana_mes
	from dw.dm_data
	group by ano, mes, semana_ano
)
update d
set semana_mes = t.semana_mes
from dw.dm_data as d
cross apply (
	select sm.semana_mes
	from semana_mes as sm
	where sm.ano = d.ano
		and sm.mes = d.mes
		and sm.semana_ano = d.semana_ano
) as t

select *
from dw.dm_data
where ano = year(current_timestamp)
order by sk_data