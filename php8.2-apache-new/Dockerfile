# Use the verified image digest for security
FROM php@sha256:7d46f3796ea2c1c1d01db4cf3f7a8336cb9aee283b077036f23fa604386fc958 as base

# Define a variable for the non-root user
ARG APP_USER=kingscode

# Install required packages with --no-install-recommends for security
USER root
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

# Remove the X-Powered-By header from PHP ini file
RUN sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/etc/php/php.ini-{development,production}

# Install PECL extensions (without mongodb)
RUN pecl install -o -f redis \
    && pecl install xdebug

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl

# Cleanup
RUN docker-php-source delete \
    && rm -rf /tmp/pear

# Set up document root and permissions for the app user
RUN mkdir -p /var/www/ \
    && useradd -ms /bin/bash ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} /var/www/

# Set Apache document root
ENV APACHE_DOCUMENT_ROOT /var/www/public

# Use Composer's verified image and install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Update Apache configuration
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable mod-rewrite
RUN a2enmod rewrite

# Set the working directory and permissions for app user
WORKDIR /var/www
RUN chown -R ${APP_USER}:${APP_USER} /var/www

# Switch to non-root user
USER ${APP_USER}

# Expose the Apache port
EXPOSE 80

CMD ["apache2-foreground"]