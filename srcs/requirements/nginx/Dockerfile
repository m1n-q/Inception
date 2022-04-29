FROM debian:buster

# cannot access docker-compse .env.
# needs own environment variable: root, url, ..

# => move to entrypoint, not build!!!

RUN apt update && apt install -y nginx

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]


