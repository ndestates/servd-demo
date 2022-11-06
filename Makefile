CONTAINER?=$(shell basename $(CURDIR))_php_1
BUILDCHAIN?=$(shell basename $(CURDIR))_webpack_1

.PHONY: build clean composer dev npm pulldb restoredb up down

build: up
	docker exec -it ${BUILDCHAIN} npm run build
clean:
	docker-compose down -v
	docker-compose up --build
composer: up
	docker exec -it ${CONTAINER} composer \
		$(filter-out $@,$(MAKECMDGOALS))
craft: up
	docker exec -it ${CONTAINER} php craft \
		$(filter-out $@,$(MAKECMDGOALS))
dev: up
npm: up
	docker exec -it ${BUILDCHAIN} npm \
		$(filter-out $@,$(MAKECMDGOALS))
pulldb: up
	cd scripts/ && ./docker_pull_db.sh
restoredb: up
	cd scripts/ && ./docker_restore_db.sh \
		$(filter-out $@,$(MAKECMDGOALS))
update:
	docker-compose down
	rm -f src/composer.lock
	rm -f docker-config/buildchain/package-lock.json
	docker-compose up
update-clean:
	docker-compose down
	sudo rm -f src/composer.lock
	sudo rm -rf src/vendor/
	sudo rm -f docker-config/buildchain/package-lock.json
	sudo rm -rf docker-config/buildchain/node_modules/
	sudo rm -rf src/storage/runtime/
	docker-compose up
down:
	docker-compose down
nuke:
	docker builder prune -a
	docker system prune -a
	docker volume prune
	sudo rm -f src/composer.lock
	# sudo rm -rf src/vendor/
	sudo rm -f docker-config/buildchain/package-lock.json
	sudo rm -rf docker-config/buildchain/node_modules/
	sudo rm -rf src/storage/runtime/
up:
	if [ ! "$$(docker ps -q -f name=${CONTAINER})" ]; then \
        docker-compose up; \
    fi
%:
	@:
# ref: https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
