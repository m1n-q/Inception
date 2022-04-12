FROM debian:buster

RUN apt update && \
	apt install -y wget php-fpm php-mysql mariadb-client && \
	wget -O /tmp/wordpress.tar.gz "http://wordpress.org/latest.tar.gz" && \
	tar -xvzf /tmp/wordpress.tar.gz -C /tmp/ && \
	rm /tmp/wordpress.tar.gz

RUN sed -e 's/\/run\/php\/php7.3-fpm.sock/9000/' \
		-i '/etc/php/7.3/fpm/pool.d/www.conf'

RUN	mkdir /var/run/php

COPY docker-entrypoint.sh /
RUN	chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
