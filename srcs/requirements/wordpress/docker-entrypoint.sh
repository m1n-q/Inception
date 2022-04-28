#!/bin/bash

#TODO: exception: if WORDPRESS_AUTH_KEY not entered
# docker-compose .env is OK in Entrypoint, while not ok in build(dockerfile)

if [ ! -e "$WP_VOLUME/wordpress/wp-config.php" ]; then
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

