#!/usr/bin/env bash

# should be /app
echo $PWD

if [[ -z $APP_SKIP_DOTENV ]]; then
    echo "Generating .env in app directory..."
    export > /home/container/app/.env
    sed -i 's/declare -x //g' /home/container/app/.env
    echo "done."
fi

echo "Setup work..."
if [[ ! -z $SETUPCMD ]]; then
    echo $SETUPCMD
    eval $SETUPCMD
fi

# make dirs
echo "Making necessary directories..."
mkdir -p /home/container/logs
mkdir -p /home/container/pids
mkdir -p /home/container/php
mkdir -p /home/container/logs/nginx

# chown workdir
echo "Acquiring permissions for working directories..."
chown -R www-data:www-data /home/container/app
chmod -R 755 /home/container/app

# setup configs
echo "Updating configurations..."
SUBSTITUTES="$(python -c 'import os; print(",".join( "${" + x + "}" for x in os.environ ))')"
function substitute {
    mkdir -p /tmp/$1
    envsubst "$SUBSTITUTES" < $1 > /tmp/$1/tmp.txt
    cat /tmp/$1/tmp.txt > $2
}

# env substitutions
substitute /home/container/config/php-fpm.conf /home/container/php/php-fpm.conf
substitute /home/container/config/php.ini /home/container/php/php.ini
substitute /home/container/config/nginx.conf /etc/nginx/sites-enabled/nginx.conf

echo "Switch to app"
cd /home/container/app

# Required nova host port and username
echo "Nova setup..."
if [[ ! -z $NOVA_PASSWORD ]]; then
    echo "{}" > auth.json && cat auth.json
    AUTHCMD="jq '.\"http-basic\".\"nova.laravel.com\".username=\"$NOVA_USERNAME\" | .\"http-basic\".\"nova.laravel.com\".password=\"$NOVA_PASSWORD\"' auth.json > auth.json.tmp"
fi
if [[ ! -z $AUTHCMD ]]; then
    eval $AUTHCMD && mv auth.json.tmp auth.json && cat auth.json
fi

# Use composer to install required PHP packages since we have some licensed packages
echo "Installing..."
if [[ -z $APP_SKIP_INSTALL ]]; then
    echo "Installing composer dependencies..."
    composer install --no-dev
else
    echo "Skipping composer install."
fi

echo "Pre-work..."
if [[ ! -z $PRECMD ]]; then
    echo $PRECMD
    eval $PRECMD
fi

echo "Start server..."
tail -F -n 100 /home/container/logs/nginx/error.log &
tail -F -n 100 /home/container/logs/nginx/access.log &
supervisord -c /home/container/supervisor/supervisord.conf
echo "Done."
