#!/bin/bash

#TODO: exception: if WORDPRESS_AUTH_KEY not entered
any=0
exit_if_empty() {
	if [ -z ${!1} ]; then
		echo "Error: check if \$$1 is set" >&2;
		any=1
	else
		echo "\$$1=${!1}"
	fi
}
default_if_empty() {
	if [ -z ${!1} ]; then
		echo "\$$1 is not set. Set to default value: $2";
		export $1=$2;
	else
		echo "\$$1=${!1}"
	fi
}

exit_if_empty "WORDPRESS_DB_HOST"
exit_if_empty "WORDPRESS_DB_NAME"
exit_if_empty "WORDPRESS_DB_USER"
exit_if_empty "WORDPRESS_DB_PASSWORD"
if [ $any != 0 ]; then
	exit $any;
fi

default_if_empty "PHP_FPM_PORT"				"/run/php/php7.3-fpm.sock"
default_if_empty "WP_VOLUME"				"/var/www/html"
default_if_empty "WORDPRESS_URL"			"http://localhost"
default_if_empty "WORDPRESS_USER_NAME"		"tester"
default_if_empty "WORDPRESS_USER_PASSWORD"	"pw"
default_if_empty "WORDPRESS_USER_EMAIL"		"tester@wp.com"


#TODO: distinguish not downloaded and not installed
if [ ! -e "$WP_VOLUME/wordpress/wp-config.php" ]; then

	# php-fpm: unix domain socket -> port
	sed -e "s|/run/php/php7.3-fpm.sock|${PHP_FPM_PORT}|" \
		-e "s/;clear_env/clear_env/" \
		-i "/etc/php/7.3/fpm/pool.d/www.conf";

	# wait for mariadb
	while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u $WORDPRESS_DB_USER -P3306 -p$WORDPRESS_DB_PASSWORD --silent; do
		echo "Waiting for mariaDB server...";
		sleep 1;
	done

	# install wordpress
	wp core download --path=$WP_VOLUME/wordpress/ --allow-root;
	mv /wp-config.php $WP_VOLUME/wordpress/;
	wp core install --url=$WORDPRESS_URL --title=Example --admin_user=$WORDPRESS_USER_NAME --admin_password=$WORDPRESS_USER_PASSWORD --admin_email=$WORDPRESS_USER_EMAIL --path=$WP_VOLUME/wordpress/ --allow-root;
fi

exec /usr/sbin/php-fpm7.3 --nodaemonize

