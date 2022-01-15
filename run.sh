#!/usr/bin/env bash

docker run --privileged -it --rm \
	        -v `readlink -f /var/run/docker.sock`:/var/run/docker.sock \
            -v ~/src:/home/raldo/src \
            -v /opt:/opt \
            ghcr.io/anguse/docker-dev:main \
            tmux -u new
