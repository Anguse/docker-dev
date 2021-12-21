all: base-dev
no-cache: base-dev/nocache

.PHONY: base-dev
base-dev:
	@docker build . -t base-dev

.PHONY: base-dev/nocache
base-dev/nocache:
	@docker build --no-cache . -t base-dev
