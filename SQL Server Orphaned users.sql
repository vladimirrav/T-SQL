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
end catch') as cmd,
	concat('--create user ', name, ' for login ', name, ';
alter role db_datareader add member ', name, ';') as usr,
	name,
	sid,
	principal_id,
	*
from sys.database_principals 
where type = 's' 
  and name not in ('guest', 'information_schema', 'sys')
  and authentication_type_desc = 'instance';

--execute sp_change_users_login update_one, 'usr', 'usr';