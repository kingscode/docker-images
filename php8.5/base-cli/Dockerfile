# PHP 8.5 CLI — workers, artisan, CI; same extensions/build-args as FrankenPHP/Apache bases.
FROM php:8.5-cli

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

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN mkdir -p ${WORKING_DIRECTORY} ${DOCUMENT_ROOT} ${BOOTSTRAP} ${LOGS} \
    && chmod -R 775 ${BOOTSTRAP} ${LOGS} ${STORAGE}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo bash nano unzip curl \
    dnsutils iputils-ping iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions \
    gd mbstring zip mysqli pdo_mysql gmp pcntl exif bcmath intl

RUN if [ "$MONGODB" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends $PHPIZE_DEPS libssl-dev && \
    curl -fsSL https://github.com/mongodb/mongo-php-driver/releases/download/2.5.5/mongodb-2.5.5.tgz -o /tmp/mongodb.tgz && \
    pecl install /tmp/mongodb.tgz && \
    docker-php-ext-enable mongodb && \
    rm -f /tmp/mongodb.tgz && \
    rm -rf /tmp/pear; \
fi

RUN if [ "$IMAGICK" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        ffmpeg \
        libmagickwand-dev \
        libmagickcore-dev \
        imagemagick \
        pkg-config && \
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

RUN rm -rf /var/lib/apt/lists/* /tmp/pear

RUN if [ "$DEVELOPMENT" = "true" ]; then \
    install-php-extensions xdebug && \
    cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini; \
else \
    cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini; \
fi

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/pear

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . /var/www

RUN chown -R ${WWW_USER}:${WWW_USER} ${STORAGE} ${BOOTSTRAP} && \
    chmod -R 775 ${STORAGE} ${BOOTSTRAP}

RUN useradd -m ${APP_USER} -u ${APP_USER_ID} && \
    chown -R ${APP_USER}:${WWW_USER} ${WORKING_DIRECTORY} && \
    chmod -R 775 ${WORKING_DIRECTORY} && \
    rm -rf /var/www/Dockerfile

RUN if [ "$DEVELOPMENT" = "true" ]; then \
    mkdir -p /home/${APP_USER} && \
    chown ${APP_USER}:${APP_USER} /home/${APP_USER} && \
    echo 'alias pa="php artisan"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias phpunit="./vendor/bin/phpunit"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias pint="./vendor/bin/pint"' >> /home/${APP_USER}/.bashrc; \
fi

USER ${APP_USER}

CMD ["php", "-v"]
