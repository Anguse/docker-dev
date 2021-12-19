#!/usr/bin/env bash

docker run --privileged -it --rm \
	        -v `readlink -f /var/run/docker.sock`:/var/run/docker.sock \
            dev-base \
            tmux -u new
