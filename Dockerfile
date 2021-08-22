FROM php:8.0.9-fpm
LABEL Maintainer="Rafael de Souza <rafael_souza31@hotmail.com>" \
      Description="Nginx 1.18 with PHP-FPM 8 on Linux."
    
RUN apt update && apt upgrade -y && apt install -y \
  wget \
  curl \
  net-tools \
  vim \
  supervisor \
  nginx \
  awscli \
  lsb-release \
  ca-certificates \
  apt-transport-https \
  software-properties-common \
  libssl-dev \
  pkg-config \
  git \
  libmcrypt-dev \
  libxml2-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libmemcached-dev \
  libpcre3-dev \
  libcurl4-openssl-dev \
  ssh-client \
  supervisor \
  zlib1g-dev \
  libicu-dev \
  libzip-dev \
  zip \
  unzip \
  g++ \
  poppler-utils \
  gnupg \
  python \
  dirmngr --install-recommends

RUN pecl install mailparse 
RUN docker-php-ext-enable opcache mailparse
RUN docker-php-ext-install \
  bcmath \
  mysqli \
  pcntl \
  pdo \
  pdo_mysql \
  gd \
  soap \
  intl

# Setup php
RUN echo "date.timezone=UTC" >  /usr/local/etc/php/conf.d/timezone.ini
RUN echo "upload_max_filesize = 10M;" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 11M;" >> /usr/local/etc/php/conf.d/uploads.ini

# Install and Enable APCu
RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

# Install and Enable Redis
RUN pecl install redis && docker-php-ext-enable redis

# Install and Enable Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install and Enable MongoDB
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Install node and npm (using version 14 as the CMS package.json has issues with version 16)
RUN apt-get update && apt-get install -my wget gnupg
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

VOLUME /var/www/html
VOLUME /var/lib/nginx
VOLUME /tmp
VOLUME /tmp/nginx
VOLUME /tmp/nginx/cache
VOLUME /tmp/nginx/fcgicache

# Configure nginx (This should be overwritten by the docker-compose "volumes" binding).
COPY ./laravel-dev/nginx.conf /etc/nginx/nginx.conf

# Configure supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Remove apt cache to make the image smaller
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get purge -y --auto-remove

# Add application
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
