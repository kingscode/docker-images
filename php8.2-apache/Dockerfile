FROM php:8.2-apache

# Install necessary packages
RUN apt-get update && apt-get install -y bash \
    && ln -sf /bin/bash /bin/sh \
    && apt-get install -y \
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
    && apt-get update && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Disable X-Powered-By header
RUN sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/etc/php/php.ini-development \
    && sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/etc/php/php.ini-production

# Install PECL extensions: Redis, Xdebug
RUN pecl install -o -f redis xdebug \
    && pecl install mongodb \
    && docker-php-ext-enable redis xdebug \


# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl exif bcmath sockets mongodb

# Cleanup after build to reduce image size
RUN docker-php-source delete \
    && rm -rf /tmp/pear

# Create a non-root user with UID 1000 and set up a home directory
RUN useradd -u 1000 -ms /bin/bash kingscode

# Change ownership of /var/www to the new user
RUN chown -R kingscode:www-data /var/www

# Set Apache to use the non-root user and group
RUN sed -i 's/User ${APACHE_RUN_USER}/User kingscode/' /etc/apache2/apache2.conf \
    && sed -i 's/Group ${APACHE_RUN_GROUP}/Group www-data/' /etc/apache2/apache2.conf

# Set working directory and adjust permissions
WORKDIR /var/www

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Switch to non-root user for the rest of the image
USER kingscode

# Setup Apache and document root for Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/public

# Update Apache configuration
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && a2enmod rewrite

# Restart Apache to apply changes
RUN service apache2 restart

# Expose HTTP port
EXPOSE 80