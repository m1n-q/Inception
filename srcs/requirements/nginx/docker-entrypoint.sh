#!/bin/bash
default_if_empty() {
	if [ -z ${!1} ]; then
		export $1=$2;
	fi
}
current_sn=$(grep '^[^\#]*server_name' "/etc/nginx/sites-available/default" | awk '{ print $2 }' | sed -e 's/.$//')
current_rt=$(grep '^[^\#]*root'		"/etc/nginx/sites-available/default" | awk '{ print $2 }' | sed -e 's/.$//')
default_if_empty "NGINX_SERVER_NAME"	"_"
default_if_empty "NGINX_ROOT_PATH"		"/var/www/html";

if [ $current_rt != $NGINX_ROOT_PATH ]; then
	echo "       root: $current_rt -> $NGINX_ROOT_PATH"
	sed -e "s|${current_rt}|${NGINX_ROOT_PATH}|" \
		-i "/etc/nginx/sites-available/default"

else
	echo "root already configured"				# DELETE
fi

if [ $current_sn != $NGINX_SERVER_NAME ]; then
	echo "server_name: $current_sn -> $NGINX_SERVER_NAME"
	sed -e "s/$current_sn;/${NGINX_SERVER_NAME};/" \
		-i "/etc/nginx/sites-available/default"
else
	echo "server_name already configured"		# DELETE
fi
# @---------------------------------- ONCE OK

if [[ -n ${NGINX_USE_FASTCGI} ]]; then
	# Check commented fastcgi_pass => uninitialized
	initial_state=$(grep '^[[:blank:]]*#.*fastcgi_pass'	"/etc/nginx/sites-available/default")
	if [[ -n $initial_state ]]; then
		echo "INIITIALIZE FASTCGI CONFIG"
		sed -e "s/index /index index.php /" \
			-e "/#location ~ \\\.php/,/}/s/#//g" \
			-e "/fastcgi_pass unix/d" \
			-e "/With php/d" \
			-i "/etc/nginx/sites-available/default";
	else
		echo "FASTCGI CONFIG ALREADY INIITIALIZED"
	fi
fi
# @---------------------------------- ONCE OK

if [[ -n ${NGINX_FASTCGI_HOST} ]] && [[ -n ${NGINX_FASTCGI_PORT} ]]; then
	echo "\$NGINX_FASTCGI_HOST=${NGINX_FASTCGI_HOST}";
	echo "\$NGINX_FASTCGI_PORT=${NGINX_FASTCGI_PORT}";

	current_cgihost=$(grep '^[^\#]*fastcgi_pass'	"/etc/nginx/sites-available/default" | awk '{ print $2 }' | awk -F: '{ print $1 }')
	current_cgiport=$(grep '^[^\#]*fastcgi_pass'	"/etc/nginx/sites-available/default" | awk '{ print $2 }' | awk -F: '{ print $2 }' | sed -e 's/.$//')
	if [[ $current_cgihost != $NGINX_FASTCGI_HOST || $current_cgiport != ${NGINX_FASTCGI_PORT} ]]; then
		echo "INITIALIZE FASTCGI HOST:PORT"
		sed -e "s/${current_cgihost}:${current_cgiport}/${NGINX_FASTCGI_HOST}:${NGINX_FASTCGI_PORT}/" \
			-i "/etc/nginx/sites-available/default";
	else
		echo "FASTCGI HOST:PORT ALREADY INIITIALIZED"
	fi
fi
# @---------------------------------- ONCE OK

if [[ ! -e "/etc/ssl/certs/selfsigned.crt" ]] || [[ ! -e "/etc/ssl/private/selfsigned.key" ]]; then
	#issue temporary self-signed cert for SSL(TLS)
	echo "Issue temporary SSL certificate"
	openssl req -x509 -text -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/selfsigned.key \
	-out /etc/ssl/certs/selfsigned.crt \
	-subj \
	"/C=${SSL_CONTRY_CODE}/ST=${SSL_STATE_NAME}/L=${SSL_LOCALITY_NAME}/O=${SSL_ORG_NAME}/OU=${SSL_ORG_UNIT}/CN=${SSL_COMMON_NAME}/emailAddress=${SSL_EMAIL_ADDRESS}";

	#nginx ssl conf
	sed -e "s|80 default_server;|443 ssl default_server;|" \
		-e "/^[^\#]*:443 ssl default_server;/a \	ssl_certificate /etc/ssl/certs/selfsigned.crt;\n	ssl_certificate_key /etc/ssl/private/selfsigned.key;\n	ssl_protocols TLSv1.2 TLSv1.3;" \
		-i "/etc/nginx/sites-available/default";
else
	echo "SSL already Configured"
fi
# @---------------------------------- ONCE OK

exec "nginx" "-g" "daemon off;"
