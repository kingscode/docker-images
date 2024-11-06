# Use php:8.2-apache as the base image
FROM php:8.2-apache AS base

# Define a non-root user for running the app securely
ARG APP_USER=kingscode
ARG APP_UID=1000

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
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
    dnsutils \
    iputils-ping \
    iproute2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PECL extensions
RUN pecl install -o -f redis && rm -rf /tmp/pear

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl

# Setup Apache document root and configure permissions
ENV APACHE_DOCUMENT_ROOT /var/www/public
RUN mkdir -p ${APACHE_DOCUMENT_ROOT} \
    && chown -R www-data:www-data /var/www \
    && useradd -ms /bin/bash -u ${APP_UID} ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} /var/www

# Update Apache config to use custom document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache mod-rewrite for frameworks (e.g., Laravel)
RUN a2enmod rewrite

# Copy Composer for dependency management
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Expose the necessary port for Apache
EXPOSE 80

# Set non-root user to prevent permissions issues when extending
USER ${APP_USER}

# Define entry point
CMD ["apache2-foreground"]
