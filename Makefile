#!/usr/bin/make

SHELL := /bin/bash
currentDir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
imageName := $(notdir $(patsubst %/,%,$(dir $(currentDir))))
dockerRegistry := registry.internal.curnowtopia.com
dockerOpts := --rm --network proxy --cap-add=NET_ADMIN -v ovpn-data-vpn.geekfundamentals.com:/usr/local/openvpn_as --device=/dev/net/tun ${imageName}:latest

docker-build:
	docker build \
	  -t ${imageName}:latest  \
	  ${currentDir}

docker-build-no-cache:
	docker build \
	  --no-cache \
	  -t ${imageName}:latest  \
	  ${currentDir}

docker-run:
	docker run --name ${imageName} -d ${dockerOpts}

docker-run-it:
	docker run --name ${imageName} ${dockerOpts}

docker-start: docker-run

docker-stop:
	docker stop ${imageName}

docker-logs:
	docker logs ${imageName}

docker-logs-f:
	docker logs --follow ${imageName}

docker-shell:
	docker exec -it ${imageName} /bin/bash

all: docker-build docker-stop docker-run docker-logs

docker-publish:
ifndef version
	@echo "Must specify 'version' when publishing."
	exit 1
endif
	docker build \
	  -t ${dockerRegistry}/${imageName}:${version} \
	  ${currentDir}

	docker push ${dockerRegistry}/${imageName}:${version}
