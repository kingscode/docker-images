# Use the official PHP image with Apache
FROM php:8.4-apache

# Define environment variables
ENV WWW_USER=www-data
ENV APP_USER=kingscode
ENV APP_USER_ID=1000
ENV ROOT_USER=root
ENV WORKING_DIRECTORY=/var/www
ENV APACHE_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public
ENV STORAGE=${WORKING_DIRECTORY}/storage
ENV BOOTSTRAP=${WORKING_DIRECTORY}/bootstrap/cache
ENV LOGS=${STORAGE}/logs

ARG DEVELOPMENT=false
ARG MONGODB=false
ARG IMAGICK=false

# Create necessary directories and set permissions
RUN mkdir -p ${WORKING_DIRECTORY} ${APACHE_DOCUMENT_ROOT} ${BOOTSTRAP} ${LOGS} \
    && chmod -R 775 ${BOOTSTRAP} ${LOGS} ${STORAGE}

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo bash nano unzip curl libjpeg62-turbo-dev libpng-dev \
    libzip-dev libgmp-dev libonig-dev libicu-dev libssl-dev pkg-config \
    mariadb-server dnsutils iputils-ping iproute2

# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl exif bcmath intl && \
    docker-php-ext-enable exif;

# Install optional extensions based on build arguments
RUN if [ "$MONGODB" = "true" ]; then \
    curl -fsSL https://github.com/mongodb/mongo-php-driver/releases/download/2.5.5/mongodb-2.5.5.tgz -o /tmp/mongodb.tgz && \
    pecl install /tmp/mongodb.tgz && \
    rm -f /tmp/mongodb.tgz && \
    docker-php-ext-enable mongodb; \
fi

RUN if [ "$IMAGICK" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        libmagickwand-dev \
        libmagickcore-dev \
        imagemagick \
        pkg-config \
        && rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://github.com/Imagick/imagick/archive/refs/tags/3.8.1.tar.gz -o /tmp/imagick.tar.gz && \
    mkdir -p /tmp/imagick && tar xzf /tmp/imagick.tar.gz -C /tmp/imagick --strip-components=1 && \
    cd /tmp/imagick && \
    phpize && \
    ./configure CPPFLAGS='-Dphp_strtolower=zend_str_tolower' && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/imagick /tmp/imagick.tar.gz && \
    docker-php-ext-enable imagick; \
fi

# Install Redis (GitHub — pecl.php.net is flaky with HTTP 500s)
RUN curl -fsSL https://github.com/phpredis/phpredis/archive/refs/tags/6.3.0.tar.gz -o /tmp/redis.tar.gz && \
    mkdir -p /tmp/redis && tar xzf /tmp/redis.tar.gz -C /tmp/redis --strip-components=1 && \
    cd /tmp/redis && phpize && ./configure && make -j$(nproc) && make install && \
    cd / && rm -rf /tmp/redis /tmp/redis.tar.gz && \
    docker-php-ext-enable redis

# Optional development tools
RUN if [ "$DEVELOPMENT" = "true" ]; then \
    curl -fsSL https://github.com/xdebug/xdebug/archive/refs/tags/3.5.3.tar.gz -o /tmp/xdebug.tar.gz && \
    mkdir -p /tmp/xdebug && tar xzf /tmp/xdebug.tar.gz -C /tmp/xdebug --strip-components=1 && \
    cd /tmp/xdebug && phpize && ./configure && make -j$(nproc) && make install && \
    cd / && rm -rf /tmp/xdebug /tmp/xdebug.tar.gz && \
    docker-php-ext-enable xdebug; \
fi

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/pear

# Enable Apache modules
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory and copy application files
WORKDIR /var/www
COPY . /var/www

# Configure Apache document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configure Apache to use port 8080
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf && \
    sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf

# Set permissions for Laravel directories
RUN chown -R ${WWW_USER}:${WWW_USER} ${STORAGE} ${BOOTSTRAP} && \
    chmod -R 775 ${STORAGE} ${BOOTSTRAP}

# Create and configure non-root user
RUN useradd -m ${APP_USER} -u ${APP_USER_ID} && \
    chown -R ${APP_USER}:${WWW_USER} ${WORKING_DIRECTORY} && \
    chmod -R 775 ${WORKING_DIRECTORY}

# Create aliases for the app user
RUN if [ "$DEVELOPMENT" = "true" ]; then \
    mkdir -p /home/${APP_USER} && \
        chown ${APP_USER}:${APP_USER} /home/${APP_USER} && \
    echo 'alias pa="php artisan"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias phpunit="./vendor/bin/phpunit"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias pint="./vendor/bin/pint"' >> /home/${APP_USER}/.bashrc; \
fi

# Switch to non-root user
USER ${APP_USER}
