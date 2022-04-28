FROM debian:buster

# cannot access docker-compse .env.
# needs own environment variable: root, url, ..

# => move to entrypoint, not build!!!

RUN apt update && apt install -y nginx
RUN sed -e "s/_;/mishin\.42\.fr;/" \
		-e "s/index /index index.php /" \
		-e "s|/var/www/html|/var/wp_volume/wordpress|" \
		-e "/#location ~ \\\.php/,/}/s/#//g" \
		-e "/fastcgi_pass unix/d" \
		-e "/With php/d" \
		-e "s/127.0.0.1/wordpress/" \
		-i "/etc/nginx/sites-available/default"

ENTRYPOINT ["nginx", "-g", "daemon off;"]

