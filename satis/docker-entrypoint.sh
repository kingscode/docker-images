#!/bin/sh

# additional SSH keys provided via volume
if [ -d /var/www/.ssh-keys ]; 
then
    cp -r /var/www/.ssh-keys/* /root/.ssh/;
    chmod 600 /root/.ssh/*
fi

sh /satis/bin/docker-entrypoint.sh