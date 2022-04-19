#!/bin/bash

#TODO: exception: if WORDPRESS_AUTH_KEY not entered

WP_ASSETS=/var/wp-assets/wordpress
if [ ! -e "$WP_ASSETS" ]; then
	mv /tmp/wordpress $WP_ASSETS;
	mv /wp-config.php $WP_ASSETS/;
	curl -d "weblog_title=MyWP&user_name=WORDMAN&admin_password=tooshort&admin_password2=tooshort&admin_email=ok@na.com" $WORDPRESS_URL:80/wp-admin/install.php?step=2
fi

#export nginx_ip=$(ping -c 1 nginx | grep PING | awk '{print $3 }' | tr -d '()')

exec /usr/sbin/php-fpm7.3 --nodaemonize

