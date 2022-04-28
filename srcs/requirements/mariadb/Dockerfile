FROM debian:buster

# install mariadb-server
RUN apt update && apt install -y mariadb-server

# allow connection from wordpress (host name)
RUN echo "\n[mysqld]\nport = 3306\nbind_address=mariadb.mynet" >> /etc/mysql/my.cnf
#RUN echo "\n[mysqld]\nport = 3306\nbind_address=127.0.0.1" >> /etc/mysql/my.cnf



# used for socket
RUN mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
	chmod 777 /var/run/mysqld && \ 
	touch /var/run/mysqld/mysqld.sock

# init db here
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
