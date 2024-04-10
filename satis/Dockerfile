FROM composer/satis:latest

RUN mkdir -p /root/.ssh
RUN ssh-keyscan -H github.com > /root/.ssh/known_hosts

RUN mkdir  -p /var/www/.ssh-keys && echo "hoi" > /var/www/.ssh-keys/test.txt

# additional SSH keys provided via volume
RUN if [ -d /var/www/.ssh-keys ]; then cp -r /var/www/.ssh-keys/* /root/.ssh/; fi

# Fix access for SSH private keys
RUN chmod 600 /root/.ssh/*