all: base-dev
no-cache: base-dev/nocache

.PHONY: base-dev
base-dev:
	@git submodule update --recursive
	@docker build . -t base-dev

.PHONY: base-dev/nocache
base-dev/nocache:
	@git submodule update --recursive
	@docker build --no-cache . -t base-dev
