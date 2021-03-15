use [db_name];

--SQL server < 2017

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
		ep.value as table_description,
		(
			select stuff((
				select concat(', ', char(13), char(10), char(9),
					iif(COLUMN_NAME like '%[ |/]%' or COLUMN_NAME like '[0-9]%',
						quotename(COLUMN_NAME),
						COLUMN_NAME
					)
				) as COLUMN_NAME
				from INFORMATION_SCHEMA.COLUMNS as cc
				where cc.TABLE_CATALOG = c.TABLE_CATALOG
					and cc.TABLE_SCHEMA = c.TABLE_SCHEMA
					and cc.TABLE_NAME = c.table_name
				order by cc.ORDINAL_POSITION
				for xml path(''), type).value('.', 'nvarchar(max)'),
			1, 2, '')
		) as columns_list
	from INFORMATION_SCHEMA.TABLES as c
	outer apply fn_listextendedproperty(null,
										'schema', c.TABLE_SCHEMA,
										'table', c.TABLE_NAME,
										null, null
									) as ep
)
select
	*,
	concat('select',
			columns_list,
			char(13), char(10),
			'from ',
			TABLE_SCHEMA,
			'.', 
			TABLE_NAME,
			';'
		) as cmd_select,
		concat('insert into ', TABLE_SCHEMA, '.', TABLE_NAME, ' (', columns_list, ')') as cmd_insert
from list
where TABLE_SCHEMA = 'table_schema'
order by TABLE_SCHEMA, TABLE_NAME;