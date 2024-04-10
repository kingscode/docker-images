#!/bin/sh

mkdir -p ~/.ssh
ssh-keyscan -H github.com > ~/.ssh/known_hosts

# additional SSH keys provided via volume
if [ -d /var/www/.ssh-keys ]; 
then
    NUMFILES=$(ls -1 /var/www/.ssh-keys | wc -l)
    echo "Found $NUMFILES additional SSH keys"
    for f in /var/www/.ssh-keys/*;
    do
        echo $(cat $f) > ~/.ssh/$(basename $f)
        echo "Copied $(basename $f)"
    done

    chmod 600 ~/.ssh*
    echo "Copied $NUMFILES additional SSH keys"
    ls -al ~/.ssh
else 
    echo "Found no additional SSH keys"App\Validators\DiscountCode\CustomerValidator
fi

echo "Running satis build"

cd /satis
php bin/satis --ansi -vvv build /build/satis.json /var/www/public