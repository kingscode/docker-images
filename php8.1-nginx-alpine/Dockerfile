FROM php:8.1-fpm-alpine

ARG user=king
ARG uid=1000
ARG development='false'

ENV DEVELOPMENT_BUILD=${development}

# Essentials
RUN echo "UTC" > /etc/timezone
RUN \
     if [[ $development = 'true' ]] ;  \
        then apk add bash nano && sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd; \
     fi


# Packages
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        # essentials
        zip unzip curl nginx openrc  \
        # gmp (arithmethic calculations)
        gmp-dev \
        # regex
        oniguruma-dev \
        # Config  \
        pcre-dev ${PHPIZE_DEPS} \
        libzip-dev

# PHP extensions
RUN docker-php-ext-install zip mysqli pdo_mysql gmp pcntl mbstring exif

#XDebug (if needed)
RUN \
     if [[ $development = 'true' ]] ;  \
        then pecl install xdebug && docker-php-ext-enable xdebug; \
     fi

#OPCache (if not development)
COPY ./php8.1-fpm/opcache.ini /usr/local/etc/php/conf.d/
RUN \
     if [[ -z $development || $development != 'true' ]] ;  \
        then \
          docker-php-ext-install opcache && docker-php-ext-enable opcache; \
     fi

# BCMath extension is required for Google Cloud Tasks
RUN docker-php-ext-install bcmath

# Redis extension
RUN pecl install -o -f redis \
   && docker-php-ext-enable redis

# GD
RUN apk add --no-cache \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        zlib-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

# Cleanup
RUN docker-php-source delete \
    && rm -rf /tmp/pear
RUN apk del pcre-dev ${PHPIZE_DEPS}

WORKDIR /var/www/

# Install composer from latest image.
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Configure nginx
COPY ./nginx/nginx-laravel.conf /etc/nginx/sites-enabled

RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN nginx -t
RUN nginx

# Configure PHP-FPM
COPY ./php8.1-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/www-data/$user/g" /usr/local/etc/php-fpm.d/www.conf

# Add user
RUN addgroup -S $user && adduser -S $user -G $user -u $uid

# In development, make /opt writable for PHPStorm (coverage)
RUN if [[ $development == 'true' ]] ;  \
    then chown $user:$user -Rf /opt && chmod -R 777 /opt; \
    fi

# Prepare laravel directories for ownage
RUN mkdir /var/www/storage /var/www/bootstrap

# Apply ownage/permissions to user
RUN chown $user:$user -Rf /var/www/storage /var/www/bootstrap /var/lib/nginx /run/nginx/nginx.pid /etc/nginx/modules
RUN chmod -R 755 /var/www/storage /var/log/nginx/error.log
RUN echo 'alias pa="php artisan"' >> /home/$user/.bashrc
RUN echo 'alias phpunit="./vendor/bin/phpunit"' >> /home/$user/.bashrc
RUN echo 'alias refresh="pa migrate:fresh"' >> /home/$user/.bashrc

USER $user