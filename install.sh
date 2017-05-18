#!/usr/bin/env bash

set -e

echo "Run composer"
docker run --env-file .env --rm -v $(PWD):$(PWD):cached -w $(PWD) -v ~/.composer:/root/.composer:cached -v ~/.ssh:/root/.ssh \
    composer create-project -s beta sylius/sylius-standard sylius --ignore-platform-reqs --no-install -n  || true

docker run --env-file .env --rm -v $(PWD):$(PWD):cached -w $(PWD)/sylius -v ~/.composer:/root/.composer:cached -v ~/.ssh:/root/.ssh \
    composer install --ignore-platform-reqs -n

echo "Run gulp"
(cd sylius && docker run --rm -ti -v $(PWD):$(PWD):cached -w $(PWD) node:6  \
    /bin/bash -c "npm install gulp-cli -g; npm install gulp -D; npm install; gulp")

echo "Copy configs"
cp docker-compose.yml sylius/docker-compose.yml
cp parameters.yml sylius/app/config/parameters.yml
cp .env sylius/app/config/.env

echo "Setup Sylius"
(cd sylius && docker-compose run sylius_web bin/console sylius:install)


echo "
What's next?

  * Run your application:
    1. Change to the project directory
    2. Execute the docker-compose up -d command;
    3. Browse to the http://localhost/ URL.

  * Read the documentation at http://docs.sylius.org/en/latest/
"