#!/bin/sh

# additional SSH keys provided via volume
if [ -d /var/www/.ssh-keys ]; 
then
    NUMFILES=$(ls -1 | wc -l)
    echo "Found $NUMFILES additional SSH keys"
    cp -r /var/www/.ssh-keys/* /root/.ssh/;
    chmod 600 /root/.ssh/*
    echo "Copied $NUMFILES additional SSH keys"
else 
    echo "Found no additional SSH keys"
fi

echo "Running satis entrypoint with args $@"
sh /satis/bin/docker-entrypoint.sh $@