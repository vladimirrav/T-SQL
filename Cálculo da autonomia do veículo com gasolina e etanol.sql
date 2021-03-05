print 'Cálculo da autonomia do veículo com gasolina/etanol';

declare @preco_g as decimal(19, 3),
		@preco_e as decimal(19, 3),
		@valor as decimal(19, 2),
		@litros as decimal(19, 2),
		@autonomia_g as decimal(19, 2) = 15.0,
		@autonomia_e as decimal(19, 2) = 10.0;

select	@preco_g = 3.738,
		@valor = 112.86,
		@litros = 0; --50; /* Se o valor for informado este é utilizado no cálculo ao invés de @valor */

print concat('Consumo', char(10), char(9), 'Gasolina: ', @autonomia_g, ' Km/L', /*char(10),*/ char(9), 'Etanol: ', @autonomia_e, ' Km/L', char(10))

set @valor = iif(nullif(@litros, 0) is not null, @litros * @preco_g, @valor);
set @litros = isnull(nullif(@litros, 0), @valor / @preco_g);
set @autonomia_g = convert(decimal(19, 2), @autonomia_g * @litros);

print concat
(	'Cálulo da autonomia com gasolina', char(10), char(9),
	'Preco/L: ', @preco_g, char(10), char(9),
	'Valor: ', @valor, char(10), char(9),
	'Litros: ', @litros, char(10), char(9),
	'Autonomia: ', @autonomia_g, ' Km', char(10)
);

/* Paralelo com etanol */

select	@preco_e = 3.270,
		@valor = 10.0,
		@litros = 0; /* Se o valor for informado este é utilizado no cálculo ao invés de @valor */

set @valor = iif(nullif(@litros, 0) is not null, @litros * @preco_e, @valor);
set @litros = isnull(nullif(@litros, 0), @valor / @preco_e);
set @autonomia_e = convert(decimal(19, 2), @autonomia_e * @litros);

print concat
(	'Cálulo da autonomia com etanol', char(10), char(9),
	'Preco/L: ', @preco_e, char(10), char(9),
	'Valor: ', @valor, char(10), char(9),
	'Litros: ', @litros, char(10), char(9),
	'Autonomia: ', @autonomia_e, ' Km', char(10)
);

/* Olhando apenas o preço - verificar a autonomia também */
print concat('Combustível mais barato: ', iif(@preco_e / @preco_g <= 0.7, 'Etanol', 'Gasolina'), ' (', convert(decimal(19, 2), @preco_e / @preco_g), ')');
print concat('Autonomia: ', iif(@autonomia_e > @autonomia_g, 'Etanol', 'Gasolina'), char(10), char(9), 'Etanol: ', @autonomia_e, char(10), char(9), 'Gasolina: ', @autonomia_g);