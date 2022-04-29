#!/bin/bash
default_if_empty() {
	if [ -z ${!1} ]; then
		export $1=$2;
	fi
}

#* allow remote connections at interface mariadb:3306
default_if_empty "MYSQL_BIND_ADDRESS"	"0.0.0.0"
default_if_empty "MYSQL_PORT"			"3306"
#'skip if already appended
echo "
[mysqld]
port=${MYSQL_PORT}
bind_address=${MYSQL_BIND_ADDRESS}
" >> /etc/mysql/my.cnf ;

#@------------------------------------------- init start
#'if db exists: skip init

#* Do a temporary startup of the MariaDB server, for init purposes
if service mysql start; then
	sleep 1;
	while ! mysqladmin -uroot ping ; do
		sleep 1;
	done
else
	echo "cannot start mariaDB server";
fi

#* create db, user
default_if_empty "MYSQL_DATABASE" "defaultdb"

if [[ $(mysql -uroot -e 'SHOW DATABASES LIKE "$MYSQL_DATABASE"') ]]; then
	echo "DB Already exists.";
else
	default_if_empty "MYSQL_ROOT_HOST"		"localhost";
	default_if_empty "MYSQL_ROOT_PASWORD"	"toor";
	default_if_empty "MYSQL_USER"			"defaultuser";
	default_if_empty "MYSQL_PASSWORD" 		"defaultpw";
	default_if_empty "MYSQL_REMOTE_HOST" 	"%";

	mysql <<- EOSQL
		CREATE DATABASE $MYSQL_DATABASE;
		CREATE USER '$MYSQL_USER'@'$MYSQL_REMOTE_HOST' IDENTIFIED BY '$MYSQL_PASSWORD';
		GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'$MYSQL_REMOTE_HOST' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;
		ALTER USER 'root'@'$MYSQL_ROOT_HOST' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
		FLUSH PRIVILEGES;
	EOSQL
fi

#* shutdown temp MariaDB server
mysqladmin shutdown -uroot -p$MYSQL_ROOT_PASSWORD
#@--------------------------------- init end
exec mysqld --defaults-file=/etc/mysql/my.cnf
