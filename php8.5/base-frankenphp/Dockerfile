# PHP 8.5 FrankenPHP — Traefik / Laravel drop-in (HTTP :8080)
# production  → distroless (default target; DEVELOPMENT=false builds)
# development → full image with shell, Composer, xdebug (DEVELOPMENT=true builds)

ARG MONGODB=false
ARG IMAGICK=false

# -----------------------------------------------------------------------------
# Shared builder: extensions + app layout + libs for distroless
# -----------------------------------------------------------------------------
FROM dunglas/frankenphp:1-php8.5 AS builder

ARG MONGODB=false
ARG IMAGICK=false

ENV WWW_USER=www-data \
    APP_USER=kingscode \
    APP_USER_ID=1000 \
    WORKING_DIRECTORY=/var/www \
    DOCUMENT_ROOT=/var/www/public \
    STORAGE=/var/www/storage \
    BOOTSTRAP=/var/www/bootstrap/cache \
    LOGS=/var/www/storage/logs \
    SERVER_NAME=:8080 \
    SERVER_ROOT=/var/www/public \
    XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data

RUN mkdir -p ${WORKING_DIRECTORY} ${DOCUMENT_ROOT} ${BOOTSTRAP} ${LOGS} \
    && chmod -R 775 ${BOOTSTRAP} ${LOGS} ${STORAGE}

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

RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

WORKDIR /var/www
COPY . /var/www
COPY Caddyfile /etc/frankenphp/Caddyfile

RUN chown -R ${WWW_USER}:${WWW_USER} ${STORAGE} ${BOOTSTRAP} && \
    chmod -R 775 ${STORAGE} ${BOOTSTRAP} && \
    useradd -m ${APP_USER} -u ${APP_USER_ID} && \
    chown -R ${APP_USER}:${WWW_USER} ${WORKING_DIRECTORY} && \
    chmod -R 775 ${WORKING_DIRECTORY} && \
    setcap -r /usr/local/bin/frankenphp && \
    chown -R ${APP_USER_ID}:${APP_USER_ID} /config/caddy /data/caddy && \
    rm -rf /var/www/Caddyfile /var/www/docker-entrypoint.sh /var/www/Dockerfile

# Collect shared libraries for distroless. Keep optional dirs non-empty for COPY.
RUN apt-get update && \
    apt-get install -y --no-install-recommends libtree && \
    mkdir -p /tmp/libs /tmp/bins /tmp/imagemagick-etc && \
    touch /tmp/bins/.keep /tmp/imagemagick-etc/.keep && \
    for target in $(which frankenphp) \
        $(find "$(php -r 'echo ini_get("extension_dir");')" -maxdepth 2 -name "*.so"); do \
        libtree -pv "$target" 2>/dev/null | grep -oP '(?:── )\K/\S+(?= \[)' | while IFS= read -r lib; do \
            [ -f "$lib" ] && cp -n "$lib" /tmp/libs/; \
        done; \
    done && \
    if [ "$IMAGICK" = "true" ]; then \
        for bin in ffmpeg ffprobe; do \
            if command -v "$bin" >/dev/null 2>&1; then \
                cp "$(command -v "$bin")" /tmp/bins/; \
                libtree -pv "$(command -v "$bin")" 2>/dev/null | grep -oP '(?:── )\K/\S+(?= \[)' | while IFS= read -r lib; do \
                    [ -f "$lib" ] && cp -n "$lib" /tmp/libs/; \
                done; \
            fi; \
        done; \
        if [ -d /etc/ImageMagick-7 ]; then cp -a /etc/ImageMagick-7 /tmp/imagemagick-etc/; fi; \
        if [ -d /etc/ImageMagick-6 ]; then cp -a /etc/ImageMagick-6 /tmp/imagemagick-etc/; fi; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# development: full image (shell, Composer, xdebug) — builds FROM builder
# -----------------------------------------------------------------------------
FROM builder AS development

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS \
    sudo bash nano unzip curl \
    dnsutils iputils-ping iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions xdebug && \
    cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir -p /home/${APP_USER} && \
    chown ${APP_USER}:${APP_USER} /home/${APP_USER} && \
    echo 'alias pa="php artisan"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias phpunit="./vendor/bin/phpunit"' >> /home/${APP_USER}/.bashrc && \
    echo 'alias pint="./vendor/bin/pint"' >> /home/${APP_USER}/.bashrc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/pear

EXPOSE 8080
USER ${APP_USER}

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["frankenphp"]

# -----------------------------------------------------------------------------
# production: Google distroless (default target — no shell / no package manager)
# -----------------------------------------------------------------------------
FROM gcr.io/distroless/base-debian13 AS production

ENV SERVER_NAME=:8080 \
    SERVER_ROOT=/var/www/public \
    XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /tmp/libs /usr/lib
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=builder /usr/local/etc/php/php.ini /usr/local/etc/php/php.ini
COPY --from=builder /etc/frankenphp/Caddyfile /etc/frankenphp/Caddyfile
COPY --from=builder --chown=1000:1000 /data /data
COPY --from=builder --chown=1000:1000 /config /config
COPY --from=builder --chown=1000:1000 /var/www /var/www
COPY --from=builder /tmp/bins/ /usr/local/bin/
COPY --from=builder /tmp/imagemagick-etc/ /etc/

WORKDIR /var/www
EXPOSE 8080
USER 1000:1000

ENTRYPOINT ["/usr/local/bin/frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--adapter", "caddyfile"]
