#!/usr/bin/env bash

docker run --privileged -it --rm \
	        -v `readlink -f /var/run/docker.sock`:/var/run/docker.sock \
            -v ~/src:/home/raldo/src \
            ghcr.io/anguse/docker-dev:main \
            tmux -u new
