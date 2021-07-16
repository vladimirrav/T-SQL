use DW;

if object_id('teste_carga') is not null
	drop table teste_carga;

create table teste_carga
(
	NU_ID int identity(1, 1) constraint PK_TESTE_CARGA primary key,
	NO_TESTE varchar(110),
	NU_CNPJ bigint,
	CO_IMPORTACAO uniqueidentifier,
	DH_IMPORTACAO datetime
);

declare @id as int = 1;

set nocount on;

while (@id < 1000000)
	begin
		insert into teste_carga (NO_TESTE, NU_CNPJ, CO_IMPORTACAO, DH_IMPORTACAO)
		values ((select left(concat(newid(), '_', newid(), '_', newid()), floor(rand() * 50) + 50)),
			convert(bigint, floor(rand() * 12544328149) * 3797),
			newid(),
			current_timestamp);
		print replace(format(@id, '#,#'), ',', '.');
		set @id += 1;
	end;

set nocount off;

--Verificar duplicados
select nu_cnpj, count(*)
from teste_carga group by NU_CNPJ
having count(*) > 1

print format(convert(bigint, floor(rand() * 12544328149) * 3797), '00_000_000/0000-00')