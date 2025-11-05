# vim:ft=make:
APP_NAME=ghcr.io/mpepping/discovery-service
OS_NAME := $(shell uname -s | tr A-Z a-z)

# Auto-detect container runtime
CONTAINER_RUNTIME := $(shell which docker 2>/dev/null || which podman 2>/dev/null || echo "")

ifeq ($(CONTAINER_RUNTIME),)
$(error No docker, podman or container found in PATH)
endif


.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the image
	$(CONTAINER_RUNTIME) build -t $(APP_NAME):latest .

push: ## Push the image
ifneq ($(findstring container,$(CONTAINER_RUNTIME)),)
	$(CONTAINER_RUNTIME) image push $(APP_NAME):latest
else
	$(CONTAINER_RUNTIME) push $(APP_NAME):latest
endif

pull: ## Pull the image
ifneq ($(findstring container,$(CONTAINER_RUNTIME)),)
	$(CONTAINER_RUNTIME) image pull $(APP_NAME):latest
else
	$(CONTAINER_RUNTIME) pull $(APP_NAME):latest
endif

clean: ## Remove the image
ifneq ($(findstring container,$(CONTAINER_RUNTIME)),)
	$(CONTAINER_RUNTIME) image rm $(APP_NAME):latest
else
	$(CONTAINER_RUNTIME) rmi $(APP_NAME):latest
endif

start: ## Start the container
	$(CONTAINER_RUNTIME) run -it --rm --name discovery-service $(APP_NAME):latest

stop: ## Stop the container
	$(CONTAINER_RUNTIME) rm -f discovery-service

test: ## Test the container build
	$(CONTAINER_RUNTIME) run -it --rm $(APP_NAME):latest \
		"env | sort"

runtime: ## Show detected container runtime and OS
	@echo "Using container runtime: $(CONTAINER_RUNTIME) on $(OS_NAME)"

