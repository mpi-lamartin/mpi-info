NIX_DEVELOP ?= nix develop --command
NPM := $(NIX_DEVELOP) npm
GIT_USER ?= fortierq

.DEFAULT_GOAL := help
.PHONY: help install dev build preview clean typecheck format format-check check deploy

help:
	@printf '%s\n' \
		'make install       Install dependencies from package-lock.json' \
		'make dev           Start the development server' \
		'make build         Build the production site' \
		'make preview       Serve the production build locally' \
		'make check         Run formatting, type, and build checks' \
		'make format        Format the project with Prettier' \
		'make deploy        Deploy the site to GitHub Pages'

install:
	$(NPM) ci

dev:
	$(NPM) run start

build:
	$(NPM) run build

preview:
	$(NPM) run serve

clean:
	$(NPM) run clear

typecheck:
	$(NPM) run typecheck

format:
	$(NPM) run format

format-check:
	$(NPM) run format:check

check: format-check typecheck build

deploy:
	GIT_USER=$(GIT_USER) $(NPM) run deploy