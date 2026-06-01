.PHONY: up down wipe rebuild

up:
	docker-compose -f docker-compose.yml up -d

down:
	docker-compose -f docker-compose.yml down

wipe:
	docker-compose -f docker-compose.yml down -v

rebuild: wipe up