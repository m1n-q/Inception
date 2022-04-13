#!/bin/bash

#TODO: if env does not exists

# Do a temporary startup of the MariaDB server, for init purposes
# mysql --daemonize
if service mysql start;  then
sleep 5 
#init wp-database with env
mysql <<- EOSQL
	CREATE DATABASE $MYSQL_DATABASE;
	CREATE USER '$MYSQL_USER'@'wordpress' IDENTIFIED BY '$MYSQL_PASSWORD';
	GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'wordpress' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;
	ALTER USER 'root'@'$MYSQL_ROOT_HOST' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	FLUSH PRIVILEGES;
EOSQL
fi
# shutdown MariaDB server
mysqladmin shutdown -uroot  -p$MYSQL_ROOT_PASSWORD

exec mysqld
