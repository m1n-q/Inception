FROM debian:buster

# install wp-cli
RUN apt update && \
	apt install -y curl wget php-fpm php-mysql mariadb-client && \
	curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /tmp/wp && \
	chmod +x /tmp/wp && \
	mv /tmp/wp /usr/local/bin/wp
	
# php-fpm: unix domain socket -> port 9000 
RUN sed -e 's/\/run\/php\/php7.3-fpm.sock/9000/' \
		-e 's/;clear_env/clear_env/' \
		-i '/etc/php/7.3/fpm/pool.d/www.conf'

RUN	mkdir /var/run/php

COPY wp-config.php /
COPY docker-entrypoint.sh /
RUN	chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
