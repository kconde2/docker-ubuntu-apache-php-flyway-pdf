FROM ubuntu:19.04

# -----------------------------------------------------------------------------
# install packages & PHP modules & tools
#  - zip
#  - nodejs
#  - pdo_mysql
#  - xdebug (dev only)
#  - xvfb wkhtmltopdf xauth required to generate pdf files
#  - wkhtmltopdf < v0.12.4 has a bug that makes it crash, so we download v0.12.5 instead
# -----------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
                       vim xvfb xauth wkhtmltopdf zlib1g-dev mysql-client logrotate \
                       curl unzip wget less supervisor libyaml-dev \
                       build-essential gnupg \
                       apache2 \
                       libapache2-mod-php7.2\
                       apachetop \
                       php7.2 \
                       php7.2-curl \
                       php7.2-fpm \
                       php7.2-mysql \
                       php7.2-zip \
                       php7.2-mbstring \
                       php7.2-opcache \
                       php-dev \
                       php-pear \
                       composer \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && wget -q -O /tmp/wkhtmltox_0.12.5-rc.deb "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb" \
    && apt install -y /tmp/wkhtmltox_0.12.5-rc.deb \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl channel-update pecl.php.net
RUN echo "\n" | pecl install -f yaml-2.0.4

# install flyway on a shared dir
ENV FLYWAY_DIR=/usr/local/lib/flyway-6.0.6
RUN wget -q -O /tmp/flyway-commandline-6.0.6-linux-x64.tar.gz \
         https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/6.0.6/flyway-commandline-6.0.6-linux-x64.tar.gz \
    && mkdir -p /usr/local/lib/ \
    && tar -C /usr/local/lib/ -xzf /tmp/flyway-commandline-6.0.6-linux-x64.tar.gz \
    && rm -rf /tmp/*

EXPOSE 80 443

# NOTE: ideally you should configure and run supervisor in foreground
