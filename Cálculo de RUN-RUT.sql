print 'Chile - Cálculo de RUT/RUN';

declare @Rut as int = 11411906;

declare @Digito as integer,
		@Contador as integer = 2,
		@Multiplo as integer,
		@Acumulador as integer = 0,
		@retorno as varchar(1),
		@CalcRUT as int = @Rut;

while @CalcRUT <> 0
begin
	set @Multiplo = (@CalcRUT % 10) * @Contador;
	set @Acumulador = @Acumulador + @Multiplo;
	set @CalcRUT = @CalcRUT / 10;
	set @Contador = @Contador + 1;
	if @Contador > 7
		set @Contador = 2;
end;

set @Digito = 11 - (@Acumulador % 11);

select @retorno = case
					when @Digito = 10 then 'K' 
					when @Digito = 11 then '0'
					else cast(@Digito as varchar(1))
				end;

print concat('RUT: ', format(@Rut, '00,000,000', 'es-cl'), '-', @retorno);

--https://es.wikipedia.org/wiki/Anexo:Implementaciones_para_algoritmo_de_rut