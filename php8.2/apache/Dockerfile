FROM thekingscode/php8.2-base

USER ${ROOT_USER}

ENV APACHE_DOCUMENT_ROOT=${WORKING_DIRECTORY}/public

RUN mkdir -p ${APACHE_DOCUMENT_ROOT}

WORKDIR ${WORKING_DIRECTORY}

# Update Apache config to use custom document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# make laravel feel comfortable with mod-rewrite
RUN a2enmod rewrite && service apache2 restart

USER ${APP_USER}

EXPOSE 80

CMD ["apache2-foreground"]
















