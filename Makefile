COMPOSE_FILE = srcs/docker-compose.yml

DC = docker compose -f $(COMPOSE_FILE)

DATA_DIR = /home/jdelorme/data
#Directorio de los volumenes persistentes

.PHONY: all upp down build start stop restart clean fclean re logs ps

all: up


up: mkdir_data
	$(DC) up -d

mkdir_data:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress


build:
	$(DC) build

down:
	$(DC) down

start:
	$(DC) start

stop:
	$(DC) stop

restart:
	$(DC) down up

logs:
	$(DC) logs -f

ps:
	$(DC) ps

clean:
	$(DC) down --rmi local -v --remove-orphans

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean all
