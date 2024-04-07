DOCKER_COMPOSE?=docker compose
EXEC=$(DOCKER_COMPOSE) exec php
CONSOLE=$(EXEC) bin/console
CONSOLE_TEST=$(EXEC) bin/console --env=test
COMPOSER=$(EXEC) composer
VENDOR_BIN=$(EXEC) vendor/bin

composer: composer.lock
	$(COMPOSER) install
	$(EXEC) vendor/bin/simple-phpunit --version

rm:
	$(DOCKER_COMPOSE) rm -f

init: stop rm build start composer db

start:
	$(DOCKER_COMPOSE) up -d --remove-orphans

stop:
	$(DOCKER_COMPOSE) stop

build:
	$(DOCKER_COMPOSE) build --pull --parallel

enter:
	$(EXEC) bash

db-migration-generate:
	$(CONSOLE) d:m:diff

db-migration-migrate:
	$(CONSOLE) d:m:m --no-interaction

db:
	$(CONSOLE) d:d:d --force
	$(CONSOLE) d:d:c
	$(CONSOLE) d:m:m --no-interaction
	$(CONSOLE) h:f:l -n

db-test:
	$(CONSOLE_TEST) d:d:d --force
	$(CONSOLE_TEST) d:d:c
	$(CONSOLE_TEST) d:m:m --no-interaction
	$(CONSOLE_TEST) h:f:l -n

db-create:
	$(CONSOLE) d:d:c

db-drop:
	$(CONSOLE) d:d:d --force

db-schema-update:
	$(CONSOLE) d:s:u --force --complete

cs-fixer: vendor
	$(VENDOR_BIN)/php-cs-fixer fix --diff --dry-run --no-interaction

cs-fixer-no-diff:
	$(VENDOR_BIN)/php-cs-fixer fix --no-interaction

phpstan: vendor
	$(VENDOR_BIN)/phpstan -l7 analyse src tests

phpmd: vendor
	$(VENDOR_BIN)/phpmd src text cleancode,codesize,controversial,design,naming,unusedcode

check-vulnerability:
	$(EXEC) ./local-php-security-checker

cc:
	$(CONSOLE) cache:clear
