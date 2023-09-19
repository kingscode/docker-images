FROM thekingscode/php8.2-cli

RUN docker-php-ext-install opcache && docker-php-ext-enable opcache \
    && docker-php-source delete \
    && rm -rf /tmp/pear

# Use production php ini
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /usr/local/etc/php/php.ini
