use DBName;

print 'Dynamic list of table columns';

select
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME,
	concat('select ',
		string_agg(
			--Check for invalid name
			iif(charindex(' ', COLUMN_NAME) > 0 or charindex('/', COLUMN_NAME) > 0 or COLUMN_NAME like '[0-9]%',
				quotename(COLUMN_NAME),
				COLUMN_NAME
			),
			', '
		) within group (order by ORDINAL_POSITION),
		char(13), char(10),
		'from ',
		iif(charindex(' ', TABLE_SCHEMA) > 0 or charindex('/', TABLE_SCHEMA) > 0 or TABLE_SCHEMA like '[0-9]%',
				quotename(TABLE_SCHEMA),
				TABLE_SCHEMA
			),
		'.', 
		iif(charindex(' ', TABLE_NAME) > 0 or charindex('/', TABLE_NAME) > 0 or TABLE_NAME like '[0-9]%',
				quotename(TABLE_NAME),
				TABLE_NAME
			),
		';'
	) as cmd_select,
	string_agg(
			iif(charindex(' ', COLUMN_NAME) > 0 or charindex('/', COLUMN_NAME) > 0 or COLUMN_NAME like '[0-9]%',
				quotename(COLUMN_NAME),
				COLUMN_NAME
			),
			', '
		) within group (order by ORDINAL_POSITION) as columns_list
from INFORMATION_SCHEMA.COLUMNS
group by
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME;