# to build the image, run:
# docker build -t victorpennington/filament-app:template --output type=docker .


FROM composer:2.9.2
FROM node:22-slim AS node_source
FROM php:8.4-fpm

WORKDIR /var/www/html
RUN apt-get update
RUN apt-get install --yes --no-install-recommends \ 
libicu-dev \
libzip-dev \ 
unzip 
RUN docker-php-ext-install zip pdo pdo_mysql intl opcache sockets

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=node_source /usr/local/bin /usr/local/bin
COPY --from=node_source /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node_source /usr/local/include/node /usr/local/include/node

#Create a symbolic link for nodeJS
RUN ln -s /usr/bin/nodejs /usr/bin/node

#Install Vite
RUN npm i vite
RUN apt-get install --yes --no-install-recommends git
RUN apt update && apt install -y sqlite3