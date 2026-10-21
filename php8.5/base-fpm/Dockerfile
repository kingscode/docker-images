# PHP 8.5 FPM + nginx — HTTP drop-in for Traefik / Laravel apps (e.g. doorless)
# Speaks HTTP on 8080 as non-root, same extensions/build-args as the Apache base image.
FROM php:8.5.12-fpm

# Define environment variables
ENV WWW_USER=www-data
ENV APP_USER=kingscode
ENV APP_USER_ID=1000
ENV ROOT_USER=root
ENV WORKING_DIRECTORY=/var/www
ENV DOCUMENT_ROOT=${WORKING_DIRECTORY}/public
ENV STORAGE=${WORKING_DIRECTORY}/storage
ENV BOOTSTRAP=${WORKING_DIRECTORY}/bootstrap/cache
ENV LOGS=${STORAGE}/logs

ARG DEVELOPMENT=false
ARG MONGODB=false
ARG IMAGICK=false

# Create necessary directories and set permissions
RUN mkdir -p ${WORKING_DIRECTORY} ${DOCUMENT_ROOT} ${BOOTSTRAP} ${LOGS} \
    && chmod -R 775 ${BOOTSTRAP} ${LOGS} ${STORAGE}

# Update and install required packages (nginx fronts PHP-FPM for HTTP :8080)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo bash nano unzip curl nginx libjpeg62-turbo-dev libpng-dev \
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

## Install Redis PECL extension
#RUN pecl install redis-5.3.7 && docker-php-ext-enable redis


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

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory and copy application files
WORKDIR /var/www
COPY . /var/www

# Set permissions for Laravel directories
RUN chown -R ${WWW_USER}:${WWW_USER} ${STORAGE} ${BOOTSTRAP} && \
    chmod -R 775 ${STORAGE} ${BOOTSTRAP}

# Create and configure non-root user
RUN useradd -m ${APP_USER} -u ${APP_USER_ID} && \
    chown -R ${APP_USER}:${WWW_USER} ${WORKING_DIRECTORY} && \
    chmod -R 775 ${WORKING_DIRECTORY}

# PHP-FPM listens locally; nginx exposes HTTP on 8080 (same contract as Apache image)
RUN mkdir -p /usr/local/var/run /tmp/nginx \
    && chown -R ${APP_USER}:${WWW_USER} /usr/local/var/run /tmp/nginx \
    && { \
        echo '[global]'; \
        echo "pid = /usr/local/var/run/php-fpm.pid"; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; \
        echo '[www]'; \
        echo "user = ${APP_USER}"; \
        echo "group = ${WWW_USER}"; \
        echo 'listen = 127.0.0.1:9000'; \
        echo 'clear_env = no'; \
        echo 'catch_workers_output = yes'; \
        echo 'decorate_workers_output = no'; \
    } > /usr/local/etc/php-fpm.d/zz-docker.conf

# nginx: non-root HTTP on 8080, Laravel public/ docroot
# (copied from build context; exclude from app tree after COPY . /var/www)
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN rm -f /etc/nginx/sites-enabled/default \
    && mkdir -p /var/lib/nginx/body /var/lib/nginx/fastcgi \
    && chown -R ${APP_USER}:${WWW_USER} /etc/nginx /var/lib/nginx /var/log/nginx \
    && chmod -R g+rwX /var/lib/nginx /var/log/nginx /tmp/nginx \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && rm -rf /var/www/nginx /var/www/docker-entrypoint.sh /var/www/Dockerfile

# Avoid shipping a default site that binds :80 as root-only
RUN rm -rf /etc/nginx/sites-enabled /etc/nginx/sites-available

# Create aliases for the app user
RUN if [ "$DEVELOPMENT" = "true" ]; then \
    mkdir -p /home/${APP_USER} && \
        chown ${APP_USER}:${APP_USER} /home/${APP_USER} && \
    echo 'alias pa="php artisan"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias phpunit="./vendor/bin/phpunit"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias pint="./vendor/bin/pint"' >> /home/${APP_USER}/.bashrc; \
fi

EXPOSE 8080

# Switch to non-root user
USER ${APP_USER}

ENTRYPOINT ["docker-entrypoint.sh"]
# Same CMD doorless already uses — entrypoint treats it as "start web stack"
CMD ["apache2-foreground"]
