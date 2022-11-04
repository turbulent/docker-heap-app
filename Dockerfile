FROM turbulent/heap-base:4.0.1
MAINTAINER Benoit Beausejour <b@turbulent.ca>

ENV heap-app 6.1.2

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y software-properties-common language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && \
  apt-get install -y \
  bsd-mailx \
  inotify-tools \
  nginx \
  nullmailer \
  time \
  zip \
  wget \
  php7.4 \
  php7.4-apcu \
  php7.4-apcu-bc \
  php7.4-bcmath \
  php7.4-bz2 \
  php7.4-cli \
  php7.4-curl \
  php7.4-dba \
  php7.4-enchant \
  php7.4-fpm \
  php7.4-gd \
  php7.4-geoip \
  php7.4-gmp \
  php7.4-intl \
  php7.4-json \
  php7.4-ldap \
  php7.4-mbstring \
  php7.4-memcached \
  php7.4-mysql \
  php7.4-odbc \
  php7.4-pgsql \
  php7.4-opcache \
  php7.4-readline \
  php7.4-redis \
  php7.4-soap \
  php7.4-sqlite3 \
  php7.4-tidy \
  php7.4-xml \
  php7.4-xmlrpc \
  php7.4-yaml \
  php7.4-zip \
  php-pear \
  php7.4-dev \
  librdkafka-dev \
  && pecl install rdkafka grpc \
  && apt-get remove -y php-pear php7.4-dev linux-headers \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && echo "extension = rdkafka.so" > /etc/php/7.4/mods-available/rdkafka.ini \
  && echo "extension = grpc.so" > /etc/php/7.4/mods-available/grpc.ini \
  && phpenmod rdkafka \
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

COPY GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat

ADD opcache-gui /var/www/php-opcache-gui
ADD phpinfo.index.php /var/www/php-info/index.php

COPY nmailer-me.tmpl /systpl/
COPY nmailer-adminaddr.tmpl /systpl/
COPY nmailer-remotes.tmpl /systpl/
COPY nmailer-defaultdomain.tmpl /systpl/
ADD run-nullmailer.sh /

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

# Install ImageMagick 7.1 https://github.com/dooman87/imagemagick-docker/blob/main/Dockerfile.ubuntu
RUN apt-get update && \
    apt-get install -y make wget gcc pkg-config autoconf curl g++ cmake clang libtool \
    # IM
    libpng16-16 libpng-dev libgomp1 ghostscript libxml2-dev libxml2-utils libfontconfig1-dev libfreetype6-dev fonts-dejavu liblcms2-dev \
    # Install manually to prevent deleting with -dev packages
    libxext6 libbrotli1 && \
    # Building ImageMagick
    wget https://imagemagick.org/archive/ImageMagick-7.1.0-52.tar.gz && \
    tar xvzf ImageMagick-7.1.0-52.tar.gz -C /tmp && \
    cd /tmp/ImageMagick-7.1.0-52 && \
    ./configure --without-magick-plus-plus --without-perl --disable-docs --disable-static && \
    make && make install && \
    ldconfig /usr/local/lib && \
    apt-get remove -y wget gcc make cmake clang curl g++ autoconf pkg-config libpng-dev libxml2-dev libfontconfig1-dev libfreetype6-dev liblcms2-dev libtool && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/ImageMagick-7.1.0-52

ADD imagemagick/policy.xml /usr/local/etc/ImageMagick-7/policy.xml

VOLUME ["/vol/logs"]
VOLUME ["/vol/spool"]

EXPOSE 80
CMD ["/run.sh"]
