# docker run --privileged -it --rm \
	        # -v `readlink -f /var/run/docker.sock`:/var/run/docker.sock \
            # dev-workspace \
            # tmux new

all: bin/example
test: lint unit-test

PLATFORM=linux

.PHONY: bin/example
bin/example:
	@docker build . -t base-dev
