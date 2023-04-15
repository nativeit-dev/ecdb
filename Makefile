DOCKER_REPO = nativeit/ecdb

.PHONY: all build run logs clean stop rm prune

all: build run logs

build: build-apache

build-apache:
	docker build ${DOCKER_FLAGS} -t ${DOCKER_REPO}:dev apache

run:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml up -d

logs:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml logs

clean: stop rm prune

stop:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml stop

rm:
	docker-compose -f ./testing/docker-compose/docker-compose.testing-default.yml rm

prune:
	docker rm `docker ps -q -a --filter status=exited`
	docker rmi `docker images -q --filter "dangling=true"`	