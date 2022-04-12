FROM debian:buster

RUN apt update && apt install -y nginx
RUN sed -e "s/index /index index.php /" \
		-e "s/var\/www\/html/var\/wp-assets\/wordpress/" \
		-e "/#location ~ \\\.php/,/}/s/#//g" \
		-e "/fastcgi_pass unix/d" \
		-e "/With php/d" \
		-e "s/127.0.0.1/wordpress/" \
		-i "/etc/nginx/sites-available/default"

ENTRYPOINT ["nginx", "-g", "daemon off;"]

