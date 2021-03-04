use DBName;

print 'Dynamic list of table columns';

;with list as
(
	select
		TABLE_CATALOG,
		iif(TABLE_SCHEMA like '%[ |/]%' or TABLE_SCHEMA like '[0-9]%',
					quotename(TABLE_SCHEMA),
					TABLE_SCHEMA
		) as TABLE_SCHEMA,
		iif(TABLE_NAME like '%[ |/]%' or TABLE_NAME like '[0-9]%',
					quotename(TABLE_NAME),
					TABLE_NAME
		) as TABLE_NAME,
		string_agg(
				iif(COLUMN_NAME like '%[ |/]%' or COLUMN_NAME like '[0-9]%',
					quotename(COLUMN_NAME),
					COLUMN_NAME
				),
				', '
		) within group (order by ORDINAL_POSITION) as columns_list
	from INFORMATION_SCHEMA.COLUMNS
	group by
		TABLE_CATALOG,
		TABLE_SCHEMA,
		TABLE_NAME
)
select
	*,
	concat('select ',
			columns_list,
			' from ',
			TABLE_SCHEMA,
			'.', 
			TABLE_NAME,
			';'
		) as cmd_select,
		concat('insert into ', TABLE_SCHEMA, '.', TABLE_NAME, ' (', columns_list, ')') as cmd_insert
from list;
