FROM --platform=linux/x86_64 php:8.3-apache

RUN apt-get install -y bash
RUN ln -sf /bin/bash /bin/sh

# remove the X-Powered-By header from PHP ini file
RUN sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/etc/php/php.ini-development
RUN sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/etc/php/php.ini-production

RUN apt-get update && apt-get upgrade -y

# Essentials
RUN apt-get install -y \
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
        # mongo requirements
        libssl-dev \
        pkg-config
        
# PECL extensions
RUN \
    pecl install -o -f redis  \
    && pecl install xdebug \
    && pecl install mongodb
    
# PHP Extensions
RUN \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl exif bcmath sockets \
    && docker-php-ext-enable redis exif bcmath sockets mongodb

# Cleanup
RUN \
    docker-php-source delete \
    && rm -rf /tmp/pear

# Create working directory
RUN mkdir -p /var/www/

ENV APACHE_DOCUMENT_ROOT /var/www/public

# Install composer from image. You may change it to the latest
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# make laravel feel comfortable with mod-rewrite
RUN a2enmod rewrite && service apache2 restart

EXPOSE 80
