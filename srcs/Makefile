DBVOLUME = /home/mishin/data/db
WPVOLUME = /home/mishin/data/wp
HOSTNAME = mishin.42.fr

start: sethost
	sudo docker-compose up -d

# down will prune networks
stop:
	sudo docker-compose stop

clean:
	sudo docker-compose down
	sudo docker image prune --all

fclean: clean
	sudo docker-compose down --volumes
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
ifeq (,$(wildcard $(DBVOLUME)))
	@echo "make DB volume directory";
	@mkdir -p $(DBVOLUME)
else
	@echo "DB volume already exists";
endif
ifeq (,$(wildcard $(WPVOLUME)))
	@echo "make Wordpress volume directory";
	@mkdir -p $(WPVOLUME)
else
	@echo "Wordpress volume already exists";
endif

