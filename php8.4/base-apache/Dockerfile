# Use the official PHP image with Apache
FROM php:8.4-apache

# Define environment variables
ENV WWW_USER=www-data
ENV APP_USER=kingscode
ENV APP_USER_ID=1000
ENV WORKING_DIRECTORY=/var/www
ENV APACHE_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public

ENV STORAGE=${WORKING_DIRECTORY}/storage
ENV BOOTSTRAP=${WORKING_DIRECTORY}/bootstrap/cache
ENV LOGS=${STORAGE}/logs

ARG DEVELOPMENT=${DEVELOPMENT:-false}
ARG MONGODB=${MONGODB:-false}
ARG IMAGICK=${IMAGICK:-false}

# Create necessary directories and set permissions
RUN mkdir -p ${WORKING_DIRECTORY} \
    && mkdir -p ${APACHE_DOCUMENT_ROOT} \
    && mkdir -p ${BOOTSTRAP} ${LOGS} \
    && chmod -R 775 ${BOOTSTRAP} ${LOGS} ${STORAGE}

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    bash \
    nano \
    unzip \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libgmp-dev \
    libonig-dev \
    libssl-dev \
    pkg-config \
    mariadb-server \
    dnsutils \
    iputils-ping \
    iproute2

# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl

# Conditionally install MongoDB, Imagick, and Development tools based on build arguments
RUN if [ "$MONGODB" = "true" ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    pkg-config && \
    pecl install mongodb && docker-php-ext-enable mongodb; \
fi

RUN if [ "$IMAGICK" = "true" ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
    libmagickwand-dev && \
    pecl install imagick && docker-php-ext-enable imagick; \
fi

RUN if [ "$DEVELOPMENT" = "true" ]; then \
    pecl install xdebug && docker-php-ext-enable xdebug && rm -rf /tmp/pear; \
fi

RUN if [ "$CLI" = "true" ]; then \
    docker-php-ext-install opcache &&  \
    docker-php-ext-enable opcache &&  \
    docker-php-source delete; \
fi

# Install PECL extensions
RUN pecl install -o -f redis

# Final cleanup after all installs
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/pear

# make laravel feel comfortable with mod-rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . /var/www

# Update Apache config to use Laravel's public directory as the document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configure Apache to use port 8080 and set ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf && \
    sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf

# Set ownership and permissions on storage and cache directories for Laravel
RUN chown -R ${WWW_USER}:${WWW_USER} ${STORAGE} ${BOOTSTRAP} && \
    chmod -R 775 ${STORAGE} ${BOOTSTRAP}

# Set up a non-root user
RUN useradd -m ${APP_USER} -u ${APP_USER_ID} && \
    chown -R ${APP_USER}:${WWW_USER} ${WORKING_DIRECTORY} && \
    chmod -R 775 ${WORKING_DIRECTORY}

# Set non-root user to prevent permissions issues when extending
USER ${APP_USER}