#!/bin/bash

cd /var/www/html && NO_DOCKER=true make prod

# replace Akeneo env
cp /var/www/html/.env  /var/www/html/.env.local
sed -i "s/APP_DATABASE_HOST=*/APP_DATABASE_HOST=$DISCUZQ_MYSQL_HOST/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_PORT=*/APP_DATABASE_PORT=$DISCUZQ_MYSQL_PORT/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_NAME=*/AKENEO_MYSQL_DATABASE=$DISCUZQ_MYSQL_HOST/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_USER=*/APP_DATABASE_USER=$ENV AKENEO_MYSQL_USER/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_PASSWORD=*/APP_DATABASE_PASSWORD=$AKENEO_MYSQL_PASSWORD/"  /var/www/html/.env.local

# replace php.ini and fpm vars
sed -i "s/memory_limit = 128M/memory_limit = 512M/"  /etc/php/7.4/fpm/php.ini
sed -i "s/listen = 9000/listen = /run/php/php7.4-fpm.sock/"  /etc/php/7.4/fpm/pool.d/www.conf

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-1000}

usermod -u $USER_ID -o www-data && groupmod -g $USER_ID -o www-data
/etc/init.d/php7.4-fpm start
exec "$@"