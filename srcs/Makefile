start:
	docker-compose up

clean: 
	docker-compose down
	docker image rm srcs_wordpress
	docker image rm srcs_nginx
	docker image rm srcs_mariadb
	docker system prune --volumes

re: clean start
	

