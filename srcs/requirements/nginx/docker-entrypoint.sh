#!/bin/bash
default_if_empty() {
	if [ -z ${!1} ]; then
		export $1=$2;
	fi
}

update_directive() {

	current=$(grep "^[^\#]*${1}" "/etc/nginx/sites-available/default" | awk '{ print $2 }' | sed -e 's/.$//')

	if [ $current != $2 ]; then
		sed -e "s|${1}[[:blank:]]*${current}|${1} ${2}|" \
			-i "/etc/nginx/sites-available/default"
		echo "[$1] updated: \"$current\" -> \"$2\""
	else
		echo "[$1] is up to date."
	fi
}

default_if_empty "NGINX_SERVER_NAME"	"_"
default_if_empty "NGINX_ROOT_PATH"		"/var/www/html";

update_directive "root" "$NGINX_ROOT_PATH"
update_directive "server_name" "$NGINX_SERVER_NAME"


# @---------------------------------- ONCE OK

if [[ -n ${NGINX_USE_FASTCGI} ]]; then

	#. Check commented fastcgi_pass => uninitialized
	initial_state=$(grep '^[[:blank:]]*#.*fastcgi_pass'	"/etc/nginx/sites-available/default")

	if [[ -n $initial_state ]]; then
		echo "initializing FASTCGI CONFIG"
		sed -e "s/index /index index.php /" \
			-e "/#location ~ \\\.php/,/}/s/#//g" \
			-e "/fastcgi_pass unix/d" \
			-e "/With php/d" \
			-i "/etc/nginx/sites-available/default";
	else
		echo "fastcgi already configured."
	fi
fi
# @---------------------------------- ONCE OK

if [[ -n ${NGINX_FASTCGI_HOST} ]] && [[ -n ${NGINX_FASTCGI_PORT} ]]; then
	echo "\$NGINX_FASTCGI_HOST=${NGINX_FASTCGI_HOST}";
	echo "\$NGINX_FASTCGI_PORT=${NGINX_FASTCGI_PORT}";

	current_fcgihost=$(grep '^[^\#]*fastcgi_pass'	"/etc/nginx/sites-available/default" | awk '{ print $2 }' | awk -F: '{ print $1 }')
	current_fcgiport=$(grep '^[^\#]*fastcgi_pass'	"/etc/nginx/sites-available/default" | awk '{ print $2 }' | awk -F: '{ print $2 }' | sed -e 's/.$//')
	if [[ $current_fcgihost != $NGINX_FASTCGI_HOST || $current_fcgiport != ${NGINX_FASTCGI_PORT} ]]; then
		sed -e "s/${current_fcgihost}:${current_fcgiport}/${NGINX_FASTCGI_HOST}:${NGINX_FASTCGI_PORT}/" \
			-i "/etc/nginx/sites-available/default";
		echo "[fastcgi HOST:PORT] updated: \"${current_fcgihost}:${current_fcgiport}\" -> \"${NGINX_FASTCGI_HOST}:${NGINX_FASTCGI_PORT}\""
	else
		echo "fastcgi HOST:PORT is up to date."
	fi
fi
# @---------------------------------- ONCE OK

if [[ ! -e "/etc/ssl/certs/selfsigned.crt" ]] || [[ ! -e "/etc/ssl/private/selfsigned.key" ]]; then

	#. issue temporary self-signed cert for SSL(TLS)
	echo "issue temporary SSL certificate"
	openssl req -x509 -text -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/selfsigned.key \
	-out /etc/ssl/certs/selfsigned.crt \
	-subj \
	"/C=${SSL_CONTRY_CODE}/ST=${SSL_STATE_NAME}/L=${SSL_LOCALITY_NAME}/O=${SSL_ORG_NAME}/OU=${SSL_ORG_UNIT}/CN=${SSL_COMMON_NAME}/emailAddress=${SSL_EMAIL_ADDRESS}";

	#. nginx ssl conf
	sed -e "s|80 default_server;|443 ssl default_server;|" \
		-e "/^[^\#]*:443 ssl default_server;/a \	ssl_certificate /etc/ssl/certs/selfsigned.crt;\n	ssl_certificate_key /etc/ssl/private/selfsigned.key;\n	ssl_protocols TLSv1.2 TLSv1.3;" \
		-i "/etc/nginx/sites-available/default";
else
	echo "SSL already configured."
fi
# @---------------------------------- ONCE OK

exec "nginx" "-g" "daemon off;"
