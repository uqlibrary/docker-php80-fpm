FROM uqlibrary/alpine:3.13.1

ENV COMPOSER_VERSION=2.0.9
ENV NEWRELIC_VERSION=9.16.0.295
ENV NR_INSTALL_SILENT=1
ENV NR_INSTALL_PHPLIST=/usr/bin
ENV BUILD_DEPS file re2c autoconf make g++ gcc groff php8-dev libmemcached-dev cyrus-sasl-dev zlib-dev pcre-dev

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
        php8-gettext php8-xmlreader php8-xmlwriter php8-xml php8-simplexml php8-bz2 php8-iconv php8-pecl-mcrypt \
        php8-pdo_dblib php8-curl php8-ctype php8-pcntl php8-posix php8-phar php8-opcache php8-mbstring php8-zlib \
        php8-fileinfo php8-tokenizer php8-sockets php8-phar php8-intl php8-pear php8-ldap php8-phpdbg php8-fpm php8 \
    # (removed since php7: php7-xmlrpc )
    #
    # Add Postgresql Client
    && apk add --update --no-cache postgresql-client \
    #
    # Add media handling tools
    && apk add --update --no-cache exiftool mediainfo \
    #
    # Install XDebug, igbinary and memcached via PECL
    && apk add --update --no-cache php8-pecl-xdebug php8-pecl-igbinary php8-pecl-memcached \
    #
    # Build deps
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    #
    # Fix php8 missing dev helpers
    && ln -s /usr/bin/php8 /usr/bin/php \
    && ln -s /usr/bin/phpize8 /usr/bin/phpize \
    && ln -s /usr/bin/php-config8 /usr/bin/php-config \
    && ln -s /usr/bin/phpdbg8 /usr/bin/phpdbg \
    #
    # Composer 2.x
    && curl -sS https://getcomposer.org/installer | php8 -- --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    #
    # NewRelic (disabled by default - not yet supported in php8)
    #&& mkdir -p /opt && cd /opt \
    #&& wget -q https://download.newrelic.com/php_agent/archive/${NEWRELIC_VERSION}/newrelic-php5-${NEWRELIC_VERSION}-linux-musl.tar.gz \
    #&& tar -zxf newrelic-php5-${NEWRELIC_VERSION}-linux-musl.tar.gz \
    #&& rm -f newrelic-php5-${NEWRELIC_VERSION}-linux-musl.tar.gz \
    #&& ./newrelic-php5-${NEWRELIC_VERSION}-linux-musl/newrelic-install install \
    #&& mv /etc/php8/conf.d/newrelic.ini /etc/newrelic.ini \
    #
    # Remove build deps
    && rm -rf /var/cache/apk/* \
    && apk del --purge .build-deps \
    #
    # Make scripts executable
    && chmod +x /usr/sbin/docker-entrypoint.sh

ADD fs /

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000

WORKDIR /app
