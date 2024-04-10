#!/bin/sh

# additional SSH keys provided via volume
if [ -d /var/www/.ssh-keys ]; 
then
    NUMFILES=$(ls -1 /var/www/.ssh-keys | wc -l)
    echo "Found $NUMFILES additional SSH keys"
    for f in /var/www/.ssh-keys/*;
    do
        echo $(cat $f) > /root/.ssh/$(basename $f)
        echo "Copied $(basename $f)"
    done

    chmod 600 /root/.ssh/*
    echo "Copied $NUMFILES additional SSH keys"
    ls -al /root/.ssh/
else 
    echo "Found no additional SSH keys"
fi

echo "Running satis build"

cd /satis
php bin/satis --ansi -vvv build /build/satis.json /var/www/public