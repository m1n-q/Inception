#!/bin/bash

#TODO: exception: if WORDPRESS_AUTH_KEY not entered
any=0
error_if_empty() {
	if [ -z "${!1}" ]; then
		echo "Error: check if $1 is set" >&2;
		any=1
	else
		echo "$1 OK"
	fi
}
default_if_empty() {
	if [ -z "${!1}" ]; then
		echo "$1 is not set. Set to default value: $2";
		export $1=$2;
	else
		echo "$1=${!1}"
	fi
}

#. --------------------------check for required env-------------------------- .#

error_if_empty "WORDPRESS_DB_HOST"
error_if_empty "WORDPRESS_DB_NAME"
error_if_empty "WORDPRESS_DB_USER"
error_if_empty "WORDPRESS_DB_PORT"
error_if_empty "WORDPRESS_DB_PASSWORD"
error_if_empty "WORDPRESS_AUTH_KEY"
error_if_empty "WORDPRESS_SECURE_AUTH_KEY"
error_if_empty "WORDPRESS_LOGGED_IN_KEY"
error_if_empty "WORDPRESS_NONCE_KEY"
error_if_empty "WORDPRESS_AUTH_SALT"
error_if_empty "WORDPRESS_SECURE_AUTH_SALT"
error_if_empty "WORDPRESS_LOGGED_IN_SALT"
error_if_empty "WORDPRESS_NONCE_SALT"

if [ $any != 0 ]; then
	exit $any;
fi
#. -------------------------------------------------------------------------- .#


default_if_empty "WP_VOLUME"				"/var/www/html"

# . Donwload wordpress (once)

if [ ! -e "$WP_VOLUME/wordpress/wp-config.php" ]; then

	default_if_empty "WORDPRESS_URL"			"http://localhost"
	default_if_empty "WORDPRESS_USER_NAME"		"wpuser"
	default_if_empty "WORDPRESS_USER_PASSWORD"	"wppw"
	default_if_empty "WORDPRESS_USER_EMAIL"		"wpuser@wp.com"

	#. wait for mariadb
	while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u $WORDPRESS_DB_USER -P"$WORDPRESS_DB_PORT" -p$WORDPRESS_DB_PASSWORD --silent; do
		echo "Waiting for mariaDB server...";
		sleep 1;
	done

	wp core download --path=$WP_VOLUME/wordpress/ --allow-root;
	mv /wp-config.php $WP_VOLUME/wordpress/;
fi


# . install wordpress (once)

installed=$(wp cache get is_blog_installed --allow-root --path=$WP_VOLUME/wordpress --quiet 2>/dev/null)

if [ ! -z $installed ] && [ $installed -eq 1 ]; then
	echo "wordpress already installed."
else
	echo "installing wordpress..."
	default_if_empty	"WORDPRESS_TITLE" "$WORDPRESS_USER_NAME's blog"
	wp core install --url=$WORDPRESS_URL --title=$WORDPRESS_TITLE --admin_user=$WORDPRESS_USER_NAME --admin_password=$WORDPRESS_USER_PASSWORD --admin_email=$WORDPRESS_USER_EMAIL --path=$WP_VOLUME/wordpress/ --allow-root;
	wp theme activate twentytwenty --path=$WP_VOLUME/wordpress/ --allow-root;
fi


#. php-fpm: unix domain socket -> port
default_if_empty "PHP_FPM_PORT"				"/run/php/php7.3-fpm.sock"

sed -e "s|/run/php/php7.3-fpm.sock|${PHP_FPM_PORT}|" \
	-e "s/;clear_env/clear_env/" \
	-i "/etc/php/7.3/fpm/pool.d/www.conf";

exec /usr/sbin/php-fpm7.3 --nodaemonize
