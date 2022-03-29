#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Provide container name as argument'
    exit 0
fi

container_name=$1

docker pull ghcr.io/anguse/docker-dev:main

docker container run -t -d --privileged --restart always --network host --name $container_name \
	-e DISPLAY=host.docker.internal:0.0 \
	-v //var/run/docker.sock:/var/run/docker.sock \
	-v //c/Users/u4023997/.wslconfig:/home/raldo/.wslconfig \
	-v //c/Users/u4023997/OneDrive\ -\ Getinge\ AB/raldo/ssh:/home/raldo/.ssh \
	-v //c/Users/u4023997/OneDrive\ -\ Getinge\ AB/raldo/vimwiki:/home/raldo/vimwiki \
	-v //c/Users/u4023997/OneDrive\ -\ Getinge\ AB/raldo/workspace:/home/raldo/workspace \
	ghcr.io/anguse/docker-dev:main zsh
