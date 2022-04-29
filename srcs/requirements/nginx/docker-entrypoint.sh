#!/bin/bash

if [ -z ${NGINX_SERVER_NAME} ]; then
	NGINX_SERVER_NAME='_';
fi
if [ -z ${NGINX_ROOT_PATH} ]; then
	NGINX_ROOT_PATH='/var/www/html';
fi

sed -e "s/_;/${NGINX_SERVER_NAME};/" \
	-e "s|/var/www/html|${NGINX_ROOT_PATH}|" \
	-i "/etc/nginx/sites-available/default"

if [[ -n ${NGINX_FASTCGI_HOST} ]] && [[ -n ${NGINX_FASTCGI_PORT} ]]; then
	echo ${NGINX_FASTCGI_HOST} ${NGINX_FASTCGI_PORT} >&2;
	sed -e "s/index /index index.php /" \
		-e "/#location ~ \\\.php/,/}/s/#//g" \
		-e "/fastcgi_pass unix/d" \
		-e "/With php/d" \
		-e "s/127.0.0.1:9000/${NGINX_FASTCGI_HOST}:${NGINX_FASTCGI_PORT}/" \
		-i "/etc/nginx/sites-available/default";
fi

exec "nginx" "-g" "daemon off;"
