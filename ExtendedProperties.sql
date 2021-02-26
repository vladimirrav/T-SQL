use BI_ANEEL;

print 'Extended properties';

;with t as
(
	select
		schema_name(o.schema_id) as SchemaName,
		convert(varchar(max), o.name) collate Latin1_General_CI_AI as TableName,
		concat('-- ', o.type_desc, ' --') collate Latin1_General_CI_AI as ColumnName,
		convert(varchar(max), ep.name) collate Latin1_General_CI_AI as PropertyName,
		convert(varchar(max), ep.value) collate Latin1_General_CI_AI as Description,
		0 as ColumnID
	from sys.objects as o
	inner join sys.tables as t on o.object_id = t.object_id
	outer apply fn_listextendedproperty(null,
										'schema', schema_name(o.schema_id),
										'table', t.name,
										null, null
									) as ep
	where o.type_desc = 'USER_TABLE'
),
c as
(
	select
		schema_name(o.schema_id) as SchemaName,
		convert(varchar(max), o.name) as TableName,
		convert(varchar(max), c.name) as ColumnName,
		convert(varchar(max), ep.name) as PropertyName,
		convert(varchar(max), ep.value) as Description,
		c.column_id as ColumnID
	from sys.objects as o
	inner join sys.columns c on o.object_id = c.object_id
	outer apply fn_listextendedproperty(default,
										'schema', schema_name(o.schema_id),
										'table', o.name,
										'column', c.name
									) as ep
)
select
	p.SchemaName,
	p.TableName,
	p.ColumnName,
	p.PropertyName,
	replace(replace(replace(p.Description, char(9), ' '), char(10), ' '), char(13), ' '),
	p.ColumnID
from (
	select * from t
	union
	select * from c
) as p
where SchemaName in('DSTRBCAO')
	--or (SchemaName in ('dbo') and TableName in ('DimAgente'))
order by SchemaName, TableName, ColumnID;
