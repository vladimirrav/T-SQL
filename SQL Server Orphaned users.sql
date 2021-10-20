use dbname;

print 'Orphaned users';

select
	concat('begin try
	alter user ', name, ' with login = ', name, ';
end try
begin catch
	print ''User: ', name, ''';
	print concat(''error_number: '', error_number());
	print concat(''error_message: '', error_message());
end catch')
	name,
	sid,
	principal_id, *
from sys.database_principals 
where type = 's' 
  and name not in ('guest', 'information_schema', 'sys')
  and authentication_type_desc = 'instance';
