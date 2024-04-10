FROM thekingscode/php8.2-apache-prod

RUN apt-get update && apt-get install -y git

COPY --from=composer/satis:latest /satis /var/www/satis

RUN mkdir -p /var/www/.ssh
RUN ssh-keyscan -H github.com > /var/www/.ssh/known_hosts

RUN chown -R www-data:www-data /var/www

USER www-data
