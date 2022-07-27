HOST_VOLUME_DIR = /home/mishin/data
DB_VOLUME = $(HOST_VOLUME_DIR)/db
WP_VOLUME = $(HOST_VOLUME_DIR)/wp
COMPOSE_FILE = srcs/docker-compose.yml
HOSTNAME = mishin.42.fr

start: mkdir sethost
	sudo docker-compose -f $(COMPOSE_FILE) up -d

# down will prune networks
stop:
	sudo docker-compose -f $(COMPOSE_FILE) stop

clean:
	sudo docker-compose -f $(COMPOSE_FILE) down
	sudo docker image prune --all

fclean: clean
	sudo docker-compose -f $(COMPOSE_FILE) down --volumes
	sudo docker system prune --volumes

re: fclean start

restart: stop start


sethost:
ifeq ($(shell grep '$(HOSTNAME)'  /etc/hosts), )
	@sudo echo "127.0.0.1 mishin.42.fr" >> /etc/hosts
else
	@echo "host name already configured"
endif

mkdir:
ifeq (,$(wildcard $(DB_VOLUME)))
	@echo "make DB volume directory";
	@mkdir -p $(DB_VOLUME)
else
	@echo "DB volume already exists";
endif
ifeq (,$(wildcard $(WP_VOLUME)))
	@echo "make Wordpress volume directory";
	@mkdir -p $(WP_VOLUME)
else
	@echo "Wordpress volume already exists";
endif

