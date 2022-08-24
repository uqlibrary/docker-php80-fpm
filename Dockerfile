FROM uqlibrary/alpine:3.15.6

ENV COMPOSER_VERSION=2.2.18

COPY ./fs/docker-entrypoint.sh /usr/sbin/docker-entrypoint.sh

RUN apk upgrade --update --no-cache && \
    apk add --update --no-cache \
    ca-certificates \
    curl \
    bash \
    git sqlite mysql-client libmemcached musl

RUN apk add --update --no-cache \
        php8-session php8-soap php8-openssl php8-gmp php8-pdo_odbc php8-json php8-dom php8-pdo php8-zip \
        php8-mysqli php8-sqlite3 php8-pdo_pgsql php8-bcmath php8-gd php8-odbc php8-pdo_mysql php8-pdo_sqlite \
        php8-gettext php8-xmlreader php8-xmlwriter php8-xml php8-simplexml php8-bz2 php8-iconv php8-xsl php8-sodium \
        php8-pdo_dblib php8-curl php8-ctype php8-pcntl php8-posix php8-phar php8-opcache php8-mbstring php8-zlib \
        php8-fileinfo php8-tokenizer php8-sockets php8-phar php8-intl php8-ldap php8-phpdbg php8-fpm php8 \
    #
    # Install PHP8 extensions XDebug, igbinary and memcached using packaged PECL builds
    && apk add --update --no-cache php8-pecl-xdebug php8-pecl-igbinary php8-pecl-memcached \
    #
    # Add Postgresql Client
    && apk add --update --no-cache postgresql-client \
    #
    # Add media handling tools
    && apk add --update --no-cache exiftool mediainfo \
    #
    # Add generic symlinks for php8 binaries
    && ln -s phar8 /usr/bin/phar \
    && ln -s php8 /usr/bin/php \
    && ln -s phpdbg8 /usr/bin/phpdbg \
    && ln -s php-fpm8 /usr/sbin/php-fpm \
    && ln -s php8 /etc/php \
    #
    # Composer 2.x
    && curl -sS https://getcomposer.org/installer | php8 -- --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    #
    # Remove build deps
    && rm -rf /var/cache/apk/* \
    #
    # Make scripts executable
    && chmod +x /usr/sbin/docker-entrypoint.sh

ADD fs /

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000

WORKDIR /app
