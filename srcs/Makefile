
HOSTNAME = mishin.42.fr

start: sethost
	docker-compose up -d

# down will prune networks
stop:
	docker-compose stop

clean:
	docker-compose down
	docker image prune --all

fclean: clean
	docker system prune --volumes

re: fclean start

restart: stop start


sethost:
ifeq ($(shell grep '$(HOSTNAME)'  /etc/hosts), )
	@sudo echo "127.0.0.1 mishin.42.fr" >> /etc/hosts
else
	@echo "host name already configured"
endif
