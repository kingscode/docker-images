# Use the official PHP image with PHP-FPM
FROM php:8.2-fpm

# Install Nginx and Supervisor
RUN apt-get update && \
    apt-get install -y nginx supervisor

# Define environment variables
ENV ROOT_USER=root
ENV APP_USER=kingscode
ENV APP_UID=1000
ENV WORKING_DIRECTORY=/var/www
ENV NGINX_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public

ENV STORAGE=${WORKING_DIRECTORY}/storage
ENV BOOTSTRAP=${WORKING_DIRECTORY}/bootstrap/cache
ENV LOGS=${STORAGE}/logs

# Create the application directory structure and set permissions
RUN mkdir -p ${WORKING_DIRECTORY} \
    && mkdir -p ${NGINX_DOCUMENT_ROOT} \
    && mkdir -p ${BOOTSTRAP} ${LOGS} \
    && useradd -ms /bin/bash -u ${APP_UID} ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} ${WORKING_DIRECTORY} \
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

# Conditionally install extensions based on build arguments
# (Add your PHP extensions here as needed)

# Install PECL extensions
RUN pecl install -o -f redis

# Final cleanup after all installs
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/pear

# Install PHP extensions (adjust as needed for your Laravel app)
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring zip mysqli pdo_mysql gmp pcntl

# Copy Composer for dependency management
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set ownership and permissions on storage and cache directories for Laravel
RUN chown -R ${APP_USER}:${APP_USER} ${STORAGE} ${BOOTSTRAP} \
    && chmod -R 775 ${STORAGE} ${BOOTSTRAP}

# Copy Nginx and Supervisor configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Switch to non-root user
USER ${APP_USER}

# Expose HTTP port
EXPOSE 80

# Start both PHP-FPM and Nginx with supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]