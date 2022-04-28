#!/bin/bash

#TODO: if env does not exists

# Do a temporary startup of the MariaDB server, for init purposes

if service mysql start; then
	sleep 1;
	while ! mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD ping ; do
		sleep 1;
	done
else
	echo "cannot start mariaDB server";
fi

if [[ $(mysql -uroot -e 'SHOW DATABASES LIKE "$MYSQL_DATABASE"') ]]; then
	echo "DB Already exists.";
else
#init wp-database with env
#TODO: if db exists: skip init 
#TODO: make 'wordpress.mynet' (hostname) able to custom
mysql <<- EOSQL
	CREATE DATABASE $MYSQL_DATABASE;
	CREATE USER '$MYSQL_USER'@'wordpress.mynet' IDENTIFIED BY '$MYSQL_PASSWORD';
	GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'wordpress.mynet' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;
	ALTER USER 'root'@'$MYSQL_ROOT_HOST' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	FLUSH PRIVILEGES;
EOSQL
fi
# shutdown MariaDB server
mysqladmin shutdown -uroot -p$MYSQL_ROOT_PASSWORD


exec mysqld --defaults-file=/etc/mysql/my.cnf
