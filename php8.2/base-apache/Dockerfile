# Use the official PHP image with Apache
FROM php:8.2-apache

# Define environment variables
ENV ROOT_USER=root
ENV APP_USER=kingscode
ENV APP_UID=1000
ENV WORKING_DIRECTORY=/var/www
ENV APACHE_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public

ENV STORAGE=${WORKING_DIRECTORY}/storage
ENV BOOTSTRAP=${WORKING_DIRECTORY}/bootstrap/cache
ENV LOGS=${STORAGE}/logs

ARG DEVELOPMENT=${DEVELOPMENT:-false}
ARG MONGODB=${MONGODB:-false}
ARG IMAGICK=${IMAGICK:-false}

# Create the application directory structure and set permissions
RUN mkdir -p ${WORKING_DIRECTORY} \
    && mkdir -p ${APACHE_DOCUMENT_ROOT} \
    && mkdir -p ${BOOTSTRAP} ${LOGS} \
    && useradd -ms /bin/bash -u ${APP_UID} ${APP_USER} \
    && chown -R www-data:www-data ${WORKING_DIRECTORY} \
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

# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl

# Copy Composer for dependency management
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Ensure composer has correct permissions
RUN chown ${APP_USER}:${APP_USER} /usr/bin/composer
RUN chown -R $APP_USER:$APP_USER /opt && chmod -R 777 /opt

RUN if [ "$DEVELOPMENT" = "true" ]; then \
    echo 'alias pa="php artisan"' >> /home/$APP_USER/.bashrc && \
    echo 'alias phpunit="./vendor/bin/phpunit"' >> /home/$APP_USER/.bashrc && \
    echo 'alias pint="./vendor/bin/pint"' >> /home/$APP_USER/.bashrc; \
fi

# Update Apache config to use custom document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set the ServerName globally to suppress warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Adjust Apache config to allow .htaccess override for Laravel mod_rewrite
RUN sed -ri -e 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Enable Apache mod_rewrite for Laravel
RUN a2enmod rewrite

# Set ownership and permissions on storage and cache directories for Laravel
RUN chown -R www-data:www-data ${STORAGE} ${BOOTSTRAP} \
    && chmod -R 775 ${STORAGE} ${BOOTSTRAP}

# Expose port 80 for Apache
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]