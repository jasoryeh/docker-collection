FROM php:8.2-fpm-alpine

# dependencies
RUN apk add \
    bash \
    git \
    curl \
    tar \
    unzip \
    ca-certificates \
    g++ \
    fontconfig \
    tzdata \
    memcached \
    wget \
    unzip \
    jq \
    openssl \
    sqlite \
    iproute2 \
    nginx \
    supervisor \
    gettext

RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions \
    gd \
    imap \
    ldap \
    xdebug \
    memcached \
    mongodb \
    redis \
    imagick \
    intl \
    zip \
    pdo_mysql \
    bcmath \
    bz2 \
    calendar \
    exif \
    gettext \
    mysqli \
    opcache \
    pdo_pgsql \
    pgsql \
    soap \
    sockets \
    mbstring \
    pcntl \
    curl \
    ffi \
    ftp \
    fileinfo \
    gettext \
    pdo \
    shmop \
    soap \
    sockets \
    xml

# workdir setup
WORKDIR /home/container

RUN curl -Ss https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN rm /etc/nginx/http.d/default.conf && mkdir -p /etc/nginx/sites-enabled && sed -i '/http {/a include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
COPY ./supervisord.conf /home/container/supervisor/
COPY ./entrypoint.sh /entrypoint.sh

COPY ./defaultapp /home/container/app
COPY . /home/container/config/

# Resolve PHP curl missing cacert.pem at some point in time,
#   this might have been already resolved, but we'll change 
#   this to download the certificate authority public keys
#   from curl.se to be safe and so that this isn't hardcoded
RUN curl "https://curl.se/ca/cacert.pem" > /home/container/app/cacert.pem

# Configurable stuff if using default config
ENV NGINX_INDEX="public.html"
ENV NGINX_ROOT="/home/container/app/public"
ENV NGINX_MAX_BODY="100m"
ENV NGINX_BODY_TIMEOUT="120s"
ENV PHP_MEMORY_LIMIT="1024M"

EXPOSE 80

CMD [ "/bin/bash", "/entrypoint.sh" ]
