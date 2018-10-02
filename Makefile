
CONTEXTO = r10k-ci-gitlab
SHELL := /bin/bash
CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VERSION:=$(shell cat .version)
ROOT_DIR := $(HOME)

NO_COLOR=\x1b[0m
GREEN_COLOR=\x1b[32;01m
RED_COLOR=\x1b[31;01m
ORANGE_COLOR=\x1b[33;01m

OK_STRING=$(GREEN_COLOR)[OK]$(NO_COLOR)
ERROR_STRING=$(RED_COLOR)[ERRORS]$(NO_COLOR)
WARN_STRING=$(ORANGE_COLOR)[WARNINGS]$(NO_COLOR)


#############
# FUNCTIONS #
#############

define msg_critical
    echo -e "$(RED_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define msg_warn
    echo -e "$(ORANGE_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define msg_ok
    echo -e "$(GREEN_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define menu
    echo -e "$(GREEN_COLOR)[$(1)]$(NO_COLOR)"
endef



.PHONY: ajuda
ajuda: help

.PHONY: limpa_tela
limpa_tela:
	@clear

.PHONY: exec_bash_env
exec_bash_env: ## Run bash (container) simulate .env
	docker run -it --rm --env-file $(CURRENT_DIR)/.env $(CONTEXTO) bash

.PHONY: exec_bash
exec_bash: ## Run bash (container)
	docker run -it --rm  \
	$(CONTEXTO) bash

.PHONY: send_git
send_git: ## Send to git (build, tests and send)
	@git pull ||   echo -e "$(ORANGE_COLOR)Could not pull$(NO_COLOR)\n"
	@make build
	git add :/ --all && git commit -m "$(VERSION)" --all || echo
	git push



.PHONY: build
build: ## Local build
	docker build -t  $(CONTEXTO) .
	make test-all

.PHONY: test-all
test-all: limpa_tela ## Tests (all)
	make test-docker

.PHONY: test-docker
test-docker:  ## Docker tests
	@echo ""
	@$(call msg_warn,"Docker basic...")
	@sleep 1; docker run --name teste-list-docker-$(CONTEXTO) --rm -it  $(CONTEXTO) | grep 10k && \
	  echo -e "\t$(GREEN_COLOR)List containers = OK $(NO_COLOR) " || \
		echo -e "\t$(RED_COLOR)List containers = NOK $(NO_COLOR) "

.PHONY: sair
sair:
	@clear

.PHONY: help
help: limpa_tela
	@$(call menu, "============== $(CONTEXTO) ==============")
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36m%-30s\033[0m %s\n", $$1, $$2}'
