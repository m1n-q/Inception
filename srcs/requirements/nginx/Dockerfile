FROM debian:buster

RUN apt update && apt install -y nginx openssl

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]


