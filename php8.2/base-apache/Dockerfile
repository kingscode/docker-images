# Use the official PHP image with Nginx
FROM php:8.2-fpm

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Define environment variables
ENV ROOT_USER=root
ENV APP_USER=kingscode
ENV APP_UID=1000
ENV WORKING_DIRECTORY=/var/www
ENV NGINX_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public

ENV STORAGE=${WORKING_DIRECTORY}/storage
ENV BOOTSTRAP=${WORKING_DIRECTORY}/bootstrap/cache
ENV LOGS=${STORAGE}/logs

ARG DEVELOPMENT=${DEVELOPMENT:-false}
ARG MONGODB=${MONGODB:-false}
ARG IMAGICK=${IMAGICK:-false}

# Create the application directory structure and set permissions
RUN mkdir -p ${WORKING_DIRECTORY} \
    && mkdir -p ${NGINX_DOCUMENT_ROOT} \
    && mkdir -p ${BOOTSTRAP} ${LOGS} \
    && useradd -ms /bin/bash -u ${APP_UID} ${APP_USER} \
    && chown -R www-data:www-data ${WORKING_DIRECTORY} \
    && chmod -R 775 ${BOOTSTRAP} ${LOGS} ${STORAGE}

# Install PHP extensions and other dependencies
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

# Set ownership and permissions on storage and cache directories for Laravel
RUN chown -R www-data:www-data ${STORAGE} ${BOOTSTRAP} \
    && chmod -R 775 ${STORAGE} ${BOOTSTRAP}

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTP port
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service php8.2-fpm start && nginx -g "daemon off;"