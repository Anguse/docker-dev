#!/usr/bin/env bash

docker pull ghcr.io/anguse/docker-dev:main

docker run --privileged -it --rm \
	        -v `readlink -f /var/run/docker.sock`:/var/run/docker.sock \
            -v ~/src:/home/raldo/src \
            -v ~/.ssh:/home/raldo/.ssh \
            -v /opt:/opt \
            ghcr.io/anguse/docker-dev:main \
            tmux -u new
