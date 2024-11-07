FROM php:8.2-apache

# Define a non-root user for running the app securely
ENV ROOT_USER=root
ENV APP_USER=kingscode
ENV APP_UID=1000
ENV WORKING_DIRECTORY=/var/www
ENV APACHE_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public

# Create a new user with a specified UID, home directory, working directory, and default shell
RUN mkdir -p ${WORKING_DIRECTORY} \
    && mkdir -p ${APACHE_DOCUMENT_ROOT} \
    && chown -R www-data:www-data ${WORKING_DIRECTORY} \
    && useradd -ms /bin/bash -u ${APP_UID} ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} ${WORKING_DIRECTORY}

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

# Copy Composer for dependency management
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR ${WORKING_DIRECTORY}

# Update Apache config to use custom document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# make laravel feel comfortable with mod-rewrite
RUN a2enmod rewrite && service apache2 restart

USER ${APP_USER}

EXPOSE 80













