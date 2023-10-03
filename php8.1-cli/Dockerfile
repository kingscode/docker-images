FROM php:8.1

RUN apk add --no-cache bash
RUN ln -sf /bin/bash /bin/sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        # utils
        nano \
        unzip \
        #gd
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        #zip
        libzip-dev \
        # gmp
        libgmp-dev \
        # regex
        libonig-dev \
    && pecl install -o -f redis \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl \
    && docker-php-ext-enable redis \
    && docker-php-source delete \
    && rm -rf /tmp/pear

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php
