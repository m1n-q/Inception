#!/bin/bash

mysql_client=(mysql)
mysql_admin=(mysqladmin)
mysql_client+=" mysql -uroot"
mysql_admin+=" -uroot"
if [ ! -z ${MYSQL_ROOT_PASSWORD} ]; then
	mysql_client+=" -p${MYSQL_ROOT_PASSWORD}"
	mysql_admin+=" -p${MYSQL_ROOT_PASSWORD}"
fi

default_if_empty() {
	if [ -z ${!1} ]; then
		export $1=$2;
	fi
}
process_sql() {
	$mysql_client <<- EOSQL
			$1
	EOSQL
}

#* allow remote connections at interface mariadb:3306
default_if_empty "MYSQL_PORT"			"3306"
default_if_empty "MYSQL_BIND_ADDRESS"	"0.0.0.0"

if ! grep -q "port=${MYSQL_PORT}" "/etc/mysql/my.cnf"; then
	echo "set bind_address to ${MYSQL_BIND_ADDRESS} . . .";
	echo "set port to ${MYSQL_PORT} . . .";
	echo "
[mysqld]
port=${MYSQL_PORT}
bind_address=${MYSQL_BIND_ADDRESS}" >> /etc/mysql/my.cnf ;
fi

#* change datadir
if [[ -n ${MYSQL_DATADIR} ]]; then
	echo "set datadir to ${MYSQL_DATADIR} . . .";
	echo "datadir=${MYSQL_DATADIR}" >> /etc/mysql/my.cnf;

	#* init datadir
	if [ ! -e ${MYSQL_DATADIR} ]; then
		echo "moving to new datadir . . . ";
		# echo "log_error=mariadb.err" >> /etc/mysql/my.cnf;
		mkdir -p ${MYSQL_DATADIR};
		mv /var/lib/mysql/* ${MYSQL_DATADIR}/;
		chown -R mysql:mysql ${MYSQL_DATADIR};
	fi
fi

#@------------------------------------------- init start

#* Do a temporary startup of the MariaDB server, for init purposes
echo "Starting temporary mariadb-server"
mysqld --defaults-file=/etc/mysql/my.cnf &
for i in {10..0}; do
	admin=
	$mysql_admin ping --silent > /dev/null;
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
done
if [ "$i" = 0 ]; then
 	echo "cannot start mariaDB server" >&2;
	exit;
fi


#* set root passwd
if [ ! -z ${MYSQL_ROOT_PASSWORD} ]; then
	default_if_empty "MYSQL_ROOT_HOST"		"localhost";
	process_sql "ALTER USER 'root'@'$MYSQL_ROOT_HOST' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"
fi



#* create db
default_if_empty "MYSQL_DATABASE" "defaultdb"
if [[ ! $($mysql_client -e "SHOW DATABASES LIKE \"${MYSQL_DATABASE}\";") ]]; then
	echo "Creating DB: ${MYSQL_DATABASE}"
	process_sql "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
fi


#* create user, give access to db
default_if_empty "MYSQL_USER"			"defaultuser";
default_if_empty "MYSQL_PASSWORD" 		"defaultpw";
default_if_empty "MYSQL_REMOTE_HOST" 	"%";
if [[ ! $($mysql_client -e "SELECT user FROM user WHERE user=\"${MYSQL_USER}\";") ]]; then
	echo "Creating user: ${MYSQL_USER}"
	process_sql  "CREATE USER IF NOT EXISTS \"${MYSQL_USER}\"@\"${MYSQL_REMOTE_HOST}\" IDENTIFIED BY \"${MYSQL_PASSWORD}\";"
	echo "Giving user ${MYSQL_USER} access to schema ${MYSQL_DATABASE}"
	process_sql	"GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'${MYSQL_REMOTE_HOST}';"
fi


#* shutdown temp MariaDB server
echo "Terminating temporary mariadb-server"
$mysql_admin shutdown
#@--------------------------------- init end

exec mysqld --defaults-file=/etc/mysql/my.cnf





