print N'Средное время в зависимости от средней скорости движения';

declare @avg_v as decimal(19, 1),	/* Средная скорость км/ч */
		@dist_km as decimal(19, 1),	/* Растояние км */
		@time as time(0),
		@crlf_t char(2);

select	@avg_v = 80,
		@dist_km = 962,
		@time = '09:05';

print concat(
		convert(nchar(20), N'Растояние'), @dist_km, N' км', char(10),
		convert(nchar(20), N'Средная скорость'), @avg_v, N' км/ч', char(10),
		convert(nchar(20), N'Километры в минуту'), convert(decimal(10, 2), @avg_v / 60), N' км/мин', char(10),
		convert(nchar(20), N'Метры в секунду'), convert(decimal(10, 1), @avg_v / 3.6), N' м/сек', char(10),
		convert(nchar(20), N'Время отправления'), @time, char(10),
		convert(nchar(20), N'Время прибытия'), convert(varchar, dateadd(second, (@dist_km /  @avg_v) * 3600, @time), 108), char(10),
		convert(nchar(20), N'Время в пути'), convert(varchar, dateadd(second, datediff(second, @time, convert(varchar, dateadd(second, (@dist_km /  @avg_v) * 3600, @time), 108)), 108), 108),
		' - ',
		datediff(minute, @time, convert(varchar, dateadd(second, (@dist_km /  @avg_v) * 3600, @time), 108)), N' мин'
	);