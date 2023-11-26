FROM php:8.2-fpm-buster

# dependencies
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt -y update && apt -y install \
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
    libmcrypt-dev \
    libicu-dev \
	libkrb5-dev \	
    libldap2-dev \	
    libldb-dev \	
    libmagickwand-dev \	
    libmcrypt-dev \	
    libmemcached-dev \
    libpq-dev \	
    libsqlite3-dev \
	libreadline-dev \	
    libxslt1-dev \	
    libzip-dev \	
    libbz2-dev \
    libc-client-dev \
    libedit-dev \
    zlib1g-dev \
    libzip-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libtool \
    libcurl4-gnutls-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    nginx \
    supervisor \
    gettext && \
    apt-get autoremove --purge -y && apt-get autoclean -y && apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*
RUN PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*
RUN docker-php-ext-install -j$(nproc) ldap && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*
RUN pecl install xdebug memcached mongodb redis && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*
RUN yes '' | pecl install imagick && docker-php-ext-enable imagick && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*
RUN docker-php-ext-enable xdebug memcached mongodb redis && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*
RUN docker-php-ext-install -j$(nproc) intl zip pdo_mysql bcmath bz2 calendar exif gettext mysqli opcache pdo_pgsql pgsql soap sockets mbstring zip pcntl curl ffi ftp fileinfo gettext pdo shmop soap sockets xml && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/tmp/*

# workdir setup
WORKDIR /home/container

RUN curl -Ss https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN rm /etc/nginx/sites-enabled/default
COPY ./supervisord.conf /home/container/supervisor/
COPY ./entrypoint.sh /entrypoint.sh
COPY ./cacert.pem /home/container/certs/
COPY ./defaultapp /home/container/app
COPY . /home/container/config/

# Configurable stuff if using default config
ENV NGINX_INDEX="public.html"
ENV NGINX_ROOT="/home/container/app/public"
ENV NGINX_MAX_BODY="100m"
ENV NGINX_BODY_TIMEOUT="120s"
ENV PHP_MEMORY_LIMIT="1024M"

EXPOSE 80

CMD [ "/bin/bash", "/entrypoint.sh" ]
