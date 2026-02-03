NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml

all: up

up:
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -f

fclean: down
	docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af
	docker volume prune -f || true

re: fclean up

.PHONY: all up down clean fclean re

