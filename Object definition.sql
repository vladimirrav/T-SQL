select object_name(id) as obj_name, *
from sys.syscomments
where [id] = object_id('objname')
order by [number];
 
select object_name(id) as obj_name, *
from sys.syscomments
where [text] LIKE '%objname%';
 
select object_name(object_id) as obj_name, *
from sys.sql_modules
where [definition] LIKE '%objname%';