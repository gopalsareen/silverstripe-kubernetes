FROM php:7.3-fpm

MAINTAINER Gopal Sareen

ARG WITH_XDEBUG=false


# Install components and PHP extensions
RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        curl \
        dnsutils \
        git \
        unzip \
        wget \
        zip \
        nano \
        libcurl4-gnutls-dev \
        libmcrypt-dev \
        libtidy-dev \
        libbz2-dev \
        libxml2-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libjpeg62 \
        libpng-dev \
        libssl-dev \
        libicu-dev \
        libc-client-dev \
        libkrb5-dev \
        jpegoptim \
        libzip-dev \
        gnupg2 \
        rsync \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-configure \
        imap --with-kerberos --with-imap-ssl \
#        zip --with-libzip \
    && docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        curl \
        ctype \
        dom \
        exif \
        fileinfo \
        ftp \
        gd \
        gettext \
        hash \
        imap \
        intl \
        json \
        mbstring \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        session \
        simplexml \
        shmop \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        tidy \
        tokenizer \
        wddx \
        xml \
        zip

# Setup X-Debug
RUN if [ $WITH_XDEBUG = "true" ] ; then \
        pecl install xdebug; \
        docker-php-ext-enable xdebug; \
        echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi ;

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
        php composer-setup.php && \
        php -r "unlink('composer-setup.php');" && \
        mv composer.phar /usr/bin/composer


# Install composer plugin that downloads packages in parallel https://github.com/hirak/prestissimo
RUN composer global require hirak/prestissimo --verbose


# Clone silverstripe recipe
RUN mkdir /bin/build-code/ && git clone https://github.com/silverstripe/recipe-cms.git /bin/build-code/

# Composer install the silvrstripe application
RUN composer install -d /bin/build-code/ \
    --ignore-platform-reqs \
    --no-interaction \
    --prefer-dist \
    --verbose


# add ss env file
COPY .silverstripe.env /bin/build-code/.env

# add post start hook script
COPY postinit.sh /bin/postinit.sh

# Setup working directory
WORKDIR /var/www/

CMD php-fpm
