FROM turbulent/heap-base:4.0.1
MAINTAINER Benoit Beausejour <b@turbulent.ca>

ENV heap-app 6.2.0

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y software-properties-common language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && \
  apt-get install -y \
  bsd-mailx \
  imagemagick \
  inotify-tools \
  nginx \
  nullmailer \
  time \
  zip \
  wget \
  libmaxminddb-dev \
  php8.1 \
  php8.1-apcu \
  php8.1-bcmath \
  php8.1-bz2 \
  php8.1-cli \
  php8.1-curl \
  php8.1-dba \
  php8.1-enchant \
  php8.1-fpm \
  php8.1-gd \
  php8.1-gmp \
  php8.1-intl \
  php8.1-ldap \
  php8.1-mbstring \
  php8.1-memcached \
  php8.1-mysql \
  php8.1-odbc \
  php8.1-pgsql \
  php8.1-opcache \
  php8.1-readline \
  php8.1-redis \
  php8.1-soap \
  php8.1-sqlite3 \
  php8.1-tidy \
  php8.1-xml \
  php8.1-xmlrpc \
  php8.1-yaml \
  php8.1-zip \
  php-pear \
  php8.1-dev \
  librdkafka-dev \
  && pecl install rdkafka grpc maxminddb \
  && apt-get remove -y php-pear php8.1-dev linux-headers \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && echo "extension = rdkafka.so" > /etc/php/8.1/mods-available/rdkafka.ini \
  && echo "extension = grpc.so" > /etc/php/8.1/mods-available/grpc.ini \
  && echo "extension = maxminddb.so" > /etc/php/8.1/mods-available/maxminddb.ini \
  && phpenmod rdkafka \
  && phpenmod maxminddb \
  && phpenmod grpc

COPY php-fpm /systpl/
COPY nginx.conf.tmpl /systpl/
COPY nginx.app.conf.tmpl /systpl/
COPY supervisor.conf.tmpl /systpl/
COPY openssl-req.conf.tmpl /systpl/
COPY fastcgi_params.tmpl /systpl/

ADD run.sh /
ADD run-fpm.sh /
ADD run-nginx.sh /

ADD ffmpeg-bin-static /opt/ffmpeg/bin

COPY GeoLite2-City.mmdb /usr/share/GeoIP/GeoLite2-City.mmdb

ADD opcache-gui /var/www/php-opcache-gui
ADD phpinfo.index.php /var/www/php-info/index.php

COPY nmailer-me.tmpl /systpl/
COPY nmailer-adminaddr.tmpl /systpl/
COPY nmailer-remotes.tmpl /systpl/
COPY nmailer-defaultdomain.tmpl /systpl/
ADD run-nullmailer.sh /
ADD imagemagick/policy.xml /etc/ImageMagick/policy.xml

RUN mkdir /tmp/php && \
  chmod 777 /tmp/php

ENV VAR_NGINX_WORKER_PROCESSES="4" \
  VAR_NGINX_WORKER_CONNECTIONS="1024" \
  VAR_NGINX_SERVER_NAME="dev.local" \
  VAR_NGINX_SERVER_ALIASES="[]" \
  VAR_NGINX_PORT="80" \
  VAR_NGINX_GZIP="true" \
  VAR_NGINX_LOADBALANCER_IPS="127.0.0.1" \
  VAR_NGINX_LOADBALANCER_HEADER="X-Forwarded-For" \
  VAR_NGINX_ALLOWED_IPS="" \
  VAR_NGINX_ALLOWED_HEAP_IPS="" \
  VAR_NGINX_MAX_BODY_SIZE="1500M" \
  VAR_NGINX_PROXY_READ_TIMEOUT="120" \
  VAR_NGINX_FASTCGI_READ_TIMEOUT="60" \
  VAR_NGINX_SSL="true" \
  VAR_NGINX_SSL_PEM="" \
  VAR_NGINX_SSL_REDIRECT="" \
  VAR_NGINX_SSL_REDIRECT_EXCEPTIONS='["/robots.txt"]' \
  VAR_NGINX_DOCROOT="/vol/website/docroot" \
  VAR_NGINX_AUTHMAP="" \
  VAR_NGINX_PROXYMAP="" \
  VAR_NGINX_UPSTREAMS="" \
  VAR_NGINX_CACHEMAP="" \
  VAR_NGINX_EXTRACONF="" \
  VAR_PHP_MAX_EXECUTION_TIME="60" \
  VAR_PHP_MEMORY_LIMIT="128M" \
  VAR_PHP_UPLOAD_MAX_FILESIZE="1024M" \
  VAR_PHP_POST_MAX_SIZE="1024M" \
  VAR_PHP_MAX_FILE_UPLOADS="1" \
  VAR_PHP_APC_SHM_SIZE="100M" \
  VAR_PHP_OPCACHE_MEMORY="128" \
  VAR_PHP_OPCACHE_REVALIDATE="2" \
  VAR_FPM_HOSTNAME="dev.local" \
  VAR_FPM="1" \
  VAR_FPM_PORT="80" \
  VAR_FPM_MAX_CHILDREN="10" \
  VAR_FPM_MIN_CHILDREN="10" \
  VAR_FPM_MAX_REQUESTS="4000" \
  VAR_FPM_REQUEST_TIMEOUT="120" \
  VAR_FPM_SLOWLOG="true" \
  VAR_FPM_SLOWLOG_TIMEOUT="120s" \
  VAR_NMAILER_HOSTNAME="hostname.example.com" \
  VAR_NMAILER_ROOT_ALIAS="sys@example.com" \
  VAR_NMAILER_DOMAIN="example.com" \
  VAR_NMAILER_REMOTE_HOST="smtp.example.com" \
  VAR_NMAILER_REMOTE_PORT="2525" \
  VAR_NMAILER_REMOTE_TLS="1" \
  VAR_NMAILER_REMOTE_USER="user@mandrillapp.com" \
  VAR_NMAILER_REMOTE_PASS="examplepass" \
  VAR_FPM_CATCH_WORKERS_OUTPUT="no"

RUN wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" \
  > /etc/apt/sources.list.d/newrelic.list'

RUN apt-get update \
  && apt-get install -y newrelic-php5 \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

COPY newrelic.ini.tmpl /systpl/

VOLUME ["/vol/logs"]
VOLUME ["/vol/spool"]

EXPOSE 80
CMD ["/run.sh"]
