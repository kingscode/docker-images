FROM thekingscode/php8.2-apache-prod

RUN apt-get update && apt-get install -y git

COPY --from=composer/satis:latest /satis /var/www/satis

RUN mkdir -p /home/root/.ssh
RUN ssh-keyscan -H github.com > /home/root/.ssh/known_hosts

# additional SSH keys provided via volume
RUN if [ -d /var/www/.ssh-keys ]; then cp -r /var/www/.ssh-keys/* /home/root/.ssh/; fi

# Fix access for SSH private keys
RUN chmod 600 /home/root/.ssh/*