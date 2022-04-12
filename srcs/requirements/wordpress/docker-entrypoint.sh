#!/bin/bash

WP_ASSETS=/var/wp-assets/wordpress
if [ ! -e "$WP_ASSETS" ]; then
	mv /tmp/wordpress $WP_ASSETS
fi

exec /usr/sbin/php-fpm7.3 --nodaemonize
