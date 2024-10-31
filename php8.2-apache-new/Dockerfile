ARG PHP_DIGEST=7d46f3796ea2c1c1d01db4cf3f7a8336cb9aee283b077036f23fa604386fc958

# Multi-stage build to reduce final image size and enhance security

# Build Stage
FROM php@sha256:${PHP_DIGEST} AS base

# Define a non-root user for running the app securely
ARG APP_USER=kingscode

# Install required packages with no recommended dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    nano \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libgmp-dev \
    libonig-dev \
    libssl-dev \
    pkg-config \
    mariadb-server \
    && ln -sf /bin/bash /bin/sh \
    && apt-get upgrade -y \
    && docker-php-source extract \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PECL extensions
RUN pecl install -o -f redis xdebug && rm -rf /tmp/pear

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl

# Setup document root and create non-root user
RUN mkdir -p /var/www/ \
    && useradd -ms /bin/bash ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} /var/www/

# Apache setup
ENV APACHE_DOCUMENT_ROOT /var/www/public
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Update Apache config to use custom document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable mod-rewrite
RUN a2enmod rewrite

# Final Stage
FROM php@sha256:${PHP_DIGEST} AS final

# Create the non-root user again in the final stage
ARG APP_USER=kingscode
RUN useradd -ms /bin/bash ${APP_USER}

COPY --from=base /var/www /var/www
COPY --from=base /usr/local/etc/php /usr/local/etc/php

# Set permissions and non-root user
RUN chown -R ${APP_USER}:${APP_USER} /var/www
USER ${APP_USER}
WORKDIR /var/www

# Expose Apache port
EXPOSE 80

CMD ["apache2-foreground"]