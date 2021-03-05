print 'Encrypting and decrypting data';

set nocount on;

declare @key as varchar(255) = newid();

declare @encrypt varbinary(200) = EncryptByPassPhrase(@key, 'Encrypted string');
print len(@encrypt)
print
	concat(
		'Key: ', @key, char(10),
		'Encrypt: ', @encrypt, char(10),
		'Decrypt: ', convert(varchar(max), DecryptByPassPhrase(@key, @encrypt))
	);

select
	@key as "Key",
	@encrypt as "Encrypt",
	convert(varchar(max), DecryptByPassPhrase(@key, @encrypt)) as "Decrypt";