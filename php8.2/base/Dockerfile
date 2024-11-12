FROM php:8.2

# Define a non-root user for running the app securely
ENV ROOT_USER=root
ENV APP_USER=kingscode
ENV APP_UID=1000
ENV WORKING_DIRECTORY=/var/www

ARG DEVELOPMENT=${DEVELOPMENT:-false}
ARG MONGODB=${MONGODB:-false}
ARG IMAGICK=${IMAGICK:-false}
ARG CLI=${CLI:-false}

# Create a new user with a specified UID, home directory, working directory, and default shell
RUN mkdir -p ${WORKING_DIRECTORY} \
    && chown -R www-data:www-data ${WORKING_DIRECTORY} \
    && useradd -ms /bin/bash -u ${APP_UID} ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} ${WORKING_DIRECTORY}

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
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

# Set non-root user to prevent permissions issues when extending
USER ${APP_USER}
