print N'Средное время в зависимости от средней скорости движения';

declare @avg_v_1 as decimal(19,2),		/* Средная скорость км/ч */
		@avg_v_2 as decimal(19,2),		/* Скорость км/ч */
		@dist_km_1 as decimal(19, 2),	/* Растояние км */
		@dist_km_2 as decimal(19, 2),	/* Растояние км */
		@time_1 as time(0),
		@time_2 as time(0),
		@crlf_t char(2);

select	@avg_v_1 = 90,
		@avg_v_2 = 90,
		@dist_km_1 = 963 ,
		@dist_km_2 = 963,
		@time_1 = '05:00',
		@time_2 = '09:00',
		@crlf_t = concat(char(10), char(9))

print concat(
		N'Туда', @crlf_t,
		N'Время отправления: ', @time_1, @crlf_t,
		N'Растояние (Км): ', @dist_km_1, @crlf_t,
		N'Средная скорость (Км/ч): ', @avg_v_1, @crlf_t,
		N'Время прибытия: ', convert(varchar, dateadd(second, (@dist_km_1 /  @avg_v_1) * 3600, @time_1), 108), @crlf_t,
		N'Время пути: ', convert(varchar, dateadd(second, datediff(second, @time_1, convert(varchar, dateadd(second, (@dist_km_1 /  @avg_v_1) * 3600, @time_1), 108)), 108), 108), @crlf_t,
		replicate(char(10), 2),
		N'Обратно', @crlf_t,
		N'Время отправления: ', @time_2, @crlf_t,
		N'Растояние (Км): ', @dist_km_2, @crlf_t,
		N'Средная скорость (Км/ч): ', @avg_v_2, @crlf_t,
		N'Время прибытия: ', convert(varchar, dateadd(second, (@dist_km_2 / @avg_v_2) * 3600, @time_2), 108), @crlf_t,
		N'Время пути: ', convert(varchar, dateadd(second, datediff(second, @time_1, convert(varchar, dateadd(second, (@dist_km_2 /  @avg_v_2) * 3600, @time_2), 108)), 108), 108)
	);

--print concat(N'Обратно', char(10), char(9), '@dist_km_2: ', @dist_km_2)