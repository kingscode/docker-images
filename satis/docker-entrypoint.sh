#!/bin/sh

# additional SSH keys provided via volume
if [ -d /var/www/.ssh-keys ]; 
then
    NUMFILES=$(ls -1 /var/www/.ssh-keys | wc -l)
    echo "Found $NUMFILES additional SSH keys"
    cp -r /var/www/.ssh-keys/* /root/.ssh/
    chmod 600 /root/.ssh/*
    echo "Copied $NUMFILES additional SSH keys"
    ls -al /root/.ssh/
else 
    echo "Found no additional SSH keys"
fi

echo "Running satis build"

cd /satis
php bin/satis --ansi -vvv build /build/satis.json /var/www/public