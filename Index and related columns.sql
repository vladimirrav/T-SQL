print 'Index and its columns';

select
	i.name as index_name,
	col_name(ic.object_id, ic.column_id) as column_name,
	ic.index_column_id,
	ic.key_ordinal,
	ic.is_included_column  
from sys.indexes AS i
inner join sys.index_columns as ic on i.object_id = ic.object_id and i.index_id = ic.index_id  
where i.name = 'index name';