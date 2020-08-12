#!/bin/bash

### clean everything except the public folder
shopt -s extglob
rm -r var/www/!(public)/

### create silverstripe cache dir
mkdir -p  /var/www/silverstripe-cache

### copy project

rsync -arql --remove-source-files /bin/build-code/ /var/www
rm -r /bin/build-code/

### set permission to public and cache dir
chown -R www-data:www-data /var/www/{public,silverstripe-cache}

### build silverstripe
php /var/www/vendor/silverstripe/framework/cli-script.php dev/build 'flush=1'